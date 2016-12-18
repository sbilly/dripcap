#include "dissector_thread.hpp"
#include "packet_dispatcher.hpp"
#include "log_message.hpp"
#include "console.hpp"
#include "layer.hpp"
#include "packet.hpp"
#include "paper_context.hpp"
#include "stream_chunk.hpp"
#include <cstdlib>
#include <nan.h>
#include <thread>
#include <unordered_set>
#include <v8.h>
#include <v8-profiler.h>
#include <v8pp/class.hpp>
#include <v8pp/object.hpp>
#include <v8pp/context.hpp>

using namespace v8;

namespace {
class ArrayBufferAllocator : public v8::ArrayBuffer::Allocator {
public:
  ArrayBufferAllocator() {}
  ~ArrayBufferAllocator() {}

  virtual void *Allocate(size_t size) { return calloc(1, size); }
  virtual void *AllocateUninitialized(size_t size) { return malloc(size); }
  virtual void Free(void *data, size_t) { free(data); }
};

struct DissectorFunc {
  std::vector<std::string> namespaces;
  std::vector<std::regex> regexNamespaces;
  v8::UniquePersistent<v8::Function> func;
};
}

class DissectorThread::Private {
public:
  Private(const std::shared_ptr<DissectorSharedContext> &ctx);
  ~Private();
  const std::vector<const DissectorFunc *> &findDessector(
      const std::string &ns,
      const std::unordered_map<std::string, DissectorFunc> &dissectors,
      std::unordered_map<std::string, std::vector<const DissectorFunc *>>
          *nsMap);

public:
  std::thread thread;
  std::shared_ptr<DissectorSharedContext> ctx;
  bool closed = false;
};

DissectorThread::Private::Private(
    const std::shared_ptr<DissectorSharedContext> &ctx)
    : ctx(ctx) {
  thread = std::thread([this]() {
    DissectorSharedContext &ctx = *this->ctx;
    v8::Isolate::CreateParams create_params;
    create_params.array_buffer_allocator = new ArrayBufferAllocator();
    v8::Isolate *isolate = v8::Isolate::New(create_params);

    // workaround for chromium task runner
    char dummyData[128] = {0};
    isolate->SetData(0, dummyData);

    static const int dissectorQuota = 512;

    {
      std::unique_ptr<v8::Locker> locker;
      v8::Isolate::Scope isolate_scope(isolate);
      if (v8::Locker::IsActive()) {
        locker.reset(new v8::Locker(isolate));
      }
      v8::HandleScope handle_scope(isolate);
      v8pp::context ppctx(isolate);
      v8::TryCatch try_catch;
      PaperContext::init(isolate);

      v8::Local<v8::Object> console =
          v8pp::class_<Console>::create_object(isolate, ctx.logCb, "dissector");
      ppctx.set("console", console);

      std::unordered_map<std::string, DissectorFunc> dissectors;
      std::unordered_map<std::string, std::vector<const DissectorFunc *>> nsMap;

      for (const Dissector &diss : ctx.dissectors) {
        v8::Local<v8::Object> moduleObj = v8::Object::New(isolate);
        ppctx.set("module", moduleObj);

        v8::Local<v8::Function> func;
        Nan::MaybeLocal<Nan::BoundScript> script = Nan::CompileScript(
            v8pp::to_v8(isolate, "(function(){" + diss.script + "})()"),
            v8::ScriptOrigin(v8pp::to_v8(isolate, diss.resourceName)));
        if (!script.IsEmpty()) {
          Nan::RunScript(script.ToLocalChecked());
          v8::Local<v8::Value> result =
              moduleObj->Get(v8::String::NewFromUtf8(isolate, "exports"));

          if (!result.IsEmpty()) {
            if (result->IsFunction()) {
              func = result.As<v8::Function>();
            } else {
              if (ctx.logCb) {
                LogMessage msg;
                msg.message = "module.exports must be a function";
                msg.domain = "dissector";
                msg.resourceName = diss.resourceName;
                ctx.logCb(msg);
              }
              continue;
            }
          }
        }
        if (func.IsEmpty()) {
          if (ctx.logCb) {
            ctx.logCb(
                LogMessage::fromMessage(try_catch.Message(), "dissector"));
          }
        } else {
          v8::Local<v8::Array> namespaces;
          std::vector<std::string> stringNamespaces;
          std::vector<std::regex> regexNamespaces;

          if (v8pp::get_option(isolate, func, "namespaces", namespaces)) {
            for (uint32_t i = 0; i < namespaces->Length(); ++i) {
              v8::Local<v8::Value> ns = namespaces->Get(i);
              if (ns->IsString()) {
                stringNamespaces.push_back(
                    v8pp::from_v8<std::string>(isolate, ns, ""));
              } else if (ns->IsRegExp()) {
                regexNamespaces.push_back(std::regex(v8pp::from_v8<std::string>(
                    isolate, ns.As<v8::RegExp>()->GetSource(), "")));
              }
            }
          }

          v8::Local<v8::Object> obj = func->NewInstance();
          if (obj.IsEmpty()) {
            if (ctx.logCb) {
              ctx.logCb(
                  LogMessage::fromMessage(try_catch.Message(), "dissector"));
            }
          } else {
            v8::Local<v8::Value> analyze =
                obj->Get(v8pp::to_v8(isolate, "analyze"));
            if (!analyze.IsEmpty() && analyze->IsFunction()) {
              v8::Local<v8::Function> analyzeFunc = analyze.As<v8::Function>();
              dissectors[diss.resourceName] = {
                  stringNamespaces, regexNamespaces,
                  v8::UniquePersistent<v8::Function>(isolate, analyzeFunc)};
            }
          }
        }
      }

      v8::Local<v8::String> profTitle = v8pp::to_v8(isolate, "diss");
      v8::CpuProfiler *prof = nullptr;
      const char *profFlag = std::getenv("PAPERFILTER_PROFILE");

      if (profFlag && strlen(profFlag)) {
        prof = isolate->GetCpuProfiler();
        prof->SetSamplingInterval(100);
        prof->StartProfiling(profTitle, true);
      }

      while (true) {
        std::unique_lock<std::mutex> lock(ctx.mutex);
        ctx.cond.wait(lock,
                      [this, &ctx] { return !ctx.queue.empty() || closed; });
        if (closed)
          break;

        std::vector<std::shared_ptr<Packet>> packets;
        for (int i = 0; i < dissectorQuota && !ctx.queue.empty(); ++i) {
          packets.push_back(std::move(ctx.queue.front()));
          ctx.queue.pop();
        }
        lock.unlock();

        for (std::shared_ptr<Packet> &pkt : packets) {
          v8::Local<v8::Object> packetObj =
              v8pp::class_<Packet>::reference_external(isolate, pkt.get());

          std::unordered_map<std::string, std::shared_ptr<Layer>> layers =
              pkt->layers();

          std::unordered_set<std::string> usedNs;
          std::vector<std::unique_ptr<StreamChunk>> streams;

          while (!layers.empty()) {
            std::unordered_map<std::string, std::shared_ptr<Layer>> nextLayers;

            for (const auto &pair : layers) {
              usedNs.insert(pair.first);
              pair.second->setPacket(pkt);

              for (const DissectorFunc *diss :
                   findDessector(pair.first, dissectors, &nsMap)) {

                v8::Local<v8::Function> analyzeFunc =
                    v8::Local<v8::Function>::New(isolate, diss->func);
                v8::Local<v8::Object> layerObj =
                    v8pp::class_<Layer>::reference_external(isolate,
                                                            pair.second.get());
                v8::Handle<v8::Value> args[2] = {packetObj, layerObj};
                v8::Local<v8::Value> result = analyzeFunc->Call(
                    isolate->GetCurrentContext()->Global(), 2, args);

                v8pp::class_<Layer>::unreference_external(isolate,
                                                          pair.second.get());

                std::vector<std::shared_ptr<Layer>> childLayers;

                if (result.IsEmpty()) {
                  if (ctx.logCb) {
                    ctx.logCb(LogMessage::fromMessage(try_catch.Message(),
                                                      "dissector"));
                  }
                } else if (result->IsArray()) {
                  v8::Local<v8::Array> array = result.As<v8::Array>();
                  for (uint32_t i = 0; i < array->Length(); ++i) {
                    if (Layer *layer = v8pp::class_<Layer>::unwrap_object(
                            isolate, array->Get(i))) {
                      childLayers.push_back(std::make_shared<Layer>(*layer));
                    } else if (StreamChunk *stream =
                                   v8pp::class_<StreamChunk>::unwrap_object(
                                       isolate, array->Get(i))) {
                      auto chunk = std::unique_ptr<StreamChunk>(
                          new StreamChunk(*stream));
                      if (!chunk->layer()) {
                        chunk->setLayer(pair.second);
                      }
                      streams.push_back(std::move(chunk));
                    }
                  }
                } else if (Layer *layer = v8pp::class_<Layer>::unwrap_object(
                               isolate, result)) {
                  childLayers.push_back(std::make_shared<Layer>(*layer));
                } else if (StreamChunk *stream =
                               v8pp::class_<StreamChunk>::unwrap_object(
                                   isolate, result)) {
                  auto chunk =
                      std::unique_ptr<StreamChunk>(new StreamChunk(*stream));
                  if (!chunk->layer()) {
                    chunk->setLayer(pair.second);
                  }
                  streams.push_back(std::move(chunk));
                }

                for (const auto &child : childLayers) {
                  nextLayers[child->ns()] = child;
                  pair.second->layers()[child->ns()] = child;
                }
              }
            }

            for (const std::string &ns : usedNs) {
              nextLayers.erase(ns);
            }
            nextLayers.swap(layers);
          }

          v8pp::class_<Packet>::unreference_external(isolate, pkt.get());

          if (ctx.streamsCb)
            ctx.streamsCb(pkt->seq(), std::move(streams));
        }

        if (ctx.packetCb)
          ctx.packetCb(packets);

        lock.lock();
      }

      if (prof) {
        v8::CpuProfile *pr = prof->StopProfiling(profTitle);
        std::function<void(const v8::CpuProfileNode *, int)> printTree;
        printTree = [&printTree](const v8::CpuProfileNode *node, int depth) {
          v8::Isolate *isolate = v8::Isolate::GetCurrent();
          const std::string &func =
              v8pp::from_v8<std::string>(isolate, node->GetFunctionName(), "");
          for (int i = 0; i < depth; ++i) {
            printf("  ");
          }
          printf("+ %d %s", node->GetHitCount(), func.c_str());
          printf("\n");

          for (int i = 0; i < node->GetChildrenCount(); ++i) {
            printTree(node->GetChild(i), depth + 1);
          }
        };

        printTree(pr->GetTopDownRoot(), 0);
        pr->Delete();
      }
    }

    isolate->Dispose();
  });
}

DissectorThread::Private::~Private() {
  {
    std::lock_guard<std::mutex> lock(ctx->mutex);
    closed = true;
  }
  ctx->cond.notify_all();
  if (thread.joinable())
    thread.join();
}

const std::vector<const DissectorFunc *> &
DissectorThread::Private::findDessector(
    const std::string &ns,
    const std::unordered_map<std::string, DissectorFunc> &dissectors,
    std::unordered_map<std::string, std::vector<const DissectorFunc *>>
        *nsMap) {
  static const std::vector<DissectorFunc *> null;

  auto it = nsMap->find(ns);
  if (it != nsMap->end())
    return it->second;

  std::vector<const DissectorFunc *> &funcs = (*nsMap)[ns];
  for (const auto &pair : dissectors) {
    const auto &diss = pair.second;
    for (const std::string &dissNs : diss.namespaces) {
      if (dissNs == ns) {
        funcs.push_back(&diss);
        break;
      }
    }
    if (funcs.empty()) {
      for (const std::regex &regex : diss.regexNamespaces) {
        if (std::regex_match(ns, regex)) {
          funcs.push_back(&diss);
          break;
        }
      }
    }
  }

  return funcs;
}

DissectorThread::DissectorThread(
    const std::shared_ptr<DissectorSharedContext> &ctx)
    : d(new Private(ctx)) {}

DissectorThread::~DissectorThread() {}
