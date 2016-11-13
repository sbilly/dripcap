#ifndef SESSION_WRAPPER_HPP
#define SESSION_WRAPPER_HPP

#include "session.hpp"
#include "session_packet_wrapper.hpp"
#include "large_buffer.hpp"
#include <nan.h>
#include <node_buffer.h>

class SessionWrapper : public Nan::ObjectWrap {
private:
  SessionWrapper(Session *session) : session(session) {}
  SessionWrapper(const SessionWrapper &) = delete;
  SessionWrapper &operator=(const SessionWrapper &) = delete;

public:
  static NAN_MODULE_INIT(Init) {
    v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
    tpl->InstanceTemplate()->SetInternalFieldCount(1);
    tpl->SetClassName(Nan::New("Session").ToLocalChecked());
    SetPrototypeMethod(tpl, "analyze", analyze);
    SetPrototypeMethod(tpl, "filter", filter);
    SetPrototypeMethod(tpl, "get", get);
    SetPrototypeMethod(tpl, "getFiltered", getFiltered);
    v8::Local<v8::ObjectTemplate> otl = tpl->InstanceTemplate();
    Nan::SetAccessor(otl, Nan::New("logCallback").ToLocalChecked(), logCallback,
                     setLogCallback);
    Nan::SetAccessor(otl, Nan::New("statusCallback").ToLocalChecked(),
                     statusCallback, setStatusCallback);
    Nan::SetAccessor(otl, Nan::New("namespace").ToLocalChecked(), ns);
    Nan::SetAccessor(otl, Nan::New("interface").ToLocalChecked(),
                     networkInterface, setInterface);
    Nan::SetAccessor(otl, Nan::New("promiscuous").ToLocalChecked(), promiscuous,
                     setPromiscuous);
    Nan::SetAccessor(otl, Nan::New("snaplen").ToLocalChecked(), snaplen,
                     setSnaplen);
    SetPrototypeMethod(tpl, "setBPF", setBPF);
    SetPrototypeMethod(tpl, "start", start);
    SetPrototypeMethod(tpl, "stop", stop);
    SetPrototypeMethod(tpl, "close", close);
    SetPrototypeMethod(tpl, "reset", reset);
    constructor().Reset(Nan::GetFunction(tpl).ToLocalChecked());

    v8::Local<v8::Object> func = Nan::GetFunction(tpl).ToLocalChecked();
    Nan::SetAccessor(func, Nan::New("devices").ToLocalChecked(), devices);
    Nan::SetAccessor(func, Nan::New("tmpDir").ToLocalChecked(), tmpDir);
    Nan::SetAccessor(func, Nan::New("permission").ToLocalChecked(), permission);
    Nan::Set(target, Nan::New("Session").ToLocalChecked(), func);
  }

  static NAN_METHOD(New) {
    if (info.IsConstructCall() && info[0]->IsObject()) {
      SessionWrapper *obj =
          new SessionWrapper(new Session(info[0].As<v8::Object>()));
      obj->Wrap(info.This());
      info.GetReturnValue().Set(info.This());
    }
  }

  static NAN_METHOD(analyze) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    if (info[0]->IsArray()) {
      v8::Local<v8::Array> array = info[0].As<v8::Array>();
      std::vector<std::unique_ptr<Packet>> packets;
      for (uint32_t i = 0; i < array->Length(); ++i) {
        packets.emplace_back(new Packet(array->Get(i).As<v8::Object>()));
      }
      wrapper->session->analyze(std::move(packets));
    } else if (info[0]->IsObject()) {
      std::unique_ptr<Packet> pkt(new Packet(info[0].As<v8::Object>()));
      wrapper->session->analyze(std::move(pkt));
    }
  }

  static NAN_METHOD(filter) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    const auto &name = Nan::Utf8String(info[0]);
    const auto &filter = Nan::Utf8String(info[1]);
    if (*name && *filter) {
      wrapper->session->filter(*name, *filter);
    }
  }

  static NAN_GETTER(logCallback) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    info.GetReturnValue().Set(wrapper->session->logCallback());
  }

  static NAN_SETTER(setLogCallback) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    if (!value.IsEmpty() && value->IsFunction()) {
      wrapper->session->setLogCallback(value.As<v8::Function>());
    }
  }

  static NAN_GETTER(statusCallback) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    info.GetReturnValue().Set(wrapper->session->statusCallback());
  }

  static NAN_SETTER(setStatusCallback) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    if (!value.IsEmpty() && value->IsFunction()) {
      wrapper->session->setStatusCallback(value.As<v8::Function>());
    }
  }

  static NAN_METHOD(get) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    auto seq = Nan::To<uint32_t>(info[0]);
    if (seq.IsJust()) {
      auto obj =
          SessionPacketWrapper::create(wrapper->session->get(seq.FromJust()));
      info.GetReturnValue().Set(obj);
    }
  }

  static NAN_METHOD(getFiltered) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;

    v8::Isolate *isolate = v8::Isolate::GetCurrent();
    const std::string &name = v8pp::from_v8<std::string>(isolate, info[0], "");
    uint32_t start = v8pp::from_v8<uint32_t>(isolate, info[1], 0);
    uint32_t end = v8pp::from_v8<uint32_t>(isolate, info[2], 0);
    const std::vector<uint32_t> &seq =
        wrapper->session->getFiltered(name, start, end);
    v8::Local<v8::Array> array = v8::Array::New(isolate, seq.size());
    for (uint32_t i = 0; i < seq.size(); ++i) {
      array->Set(i, v8::Number::New(isolate, seq[i]));
    }
    info.GetReturnValue().Set(array);
  }

  static NAN_GETTER(ns) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    info.GetReturnValue().Set(
        Nan::New(wrapper->session->ns()).ToLocalChecked());
  }

  static NAN_GETTER(permission) {
    info.GetReturnValue().Set(Session::permission());
  }

  static NAN_GETTER(devices) { info.GetReturnValue().Set(Session::devices()); }

  static NAN_GETTER(tmpDir) {
    v8::Isolate *isolate = v8::Isolate::GetCurrent();
    info.GetReturnValue().Set(v8pp::to_v8(isolate, LargeBuffer::tmpDir()));
  }

  static NAN_GETTER(networkInterface) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    info.GetReturnValue().Set(
        Nan::New<v8::String>(wrapper->session->networkInterface())
            .ToLocalChecked());
  }

  static NAN_SETTER(setInterface) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    wrapper->session->setInterface(*Nan::Utf8String(value));
  }

  static NAN_GETTER(promiscuous) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    info.GetReturnValue().Set(wrapper->session->promiscuous());
  }

  static NAN_SETTER(setPromiscuous) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    wrapper->session->setPromiscuous(value->BooleanValue());
  }

  static NAN_GETTER(snaplen) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    info.GetReturnValue().Set(wrapper->session->snaplen());
  }

  static NAN_SETTER(setSnaplen) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    wrapper->session->setSnaplen(value->IntegerValue());
  }

  static NAN_METHOD(setBPF) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    const std::string &bpf = *Nan::Utf8String(info[0]);
    std::string err;
    if (!wrapper->session->setBPF(bpf, &err)) {
      Nan::ThrowSyntaxError(err.c_str());
    }
  }

  static NAN_METHOD(start) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    wrapper->session->start();
  }

  static NAN_METHOD(stop) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    wrapper->session->stop();
  }

  static NAN_METHOD(close) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session)
      return;
    wrapper->session->stop();
    wrapper->session.reset();
  }

  static NAN_METHOD(reset) {
    SessionWrapper *wrapper = ObjectWrap::Unwrap<SessionWrapper>(info.Holder());
    if (!wrapper->session || !info[0]->IsObject())
      return;
    wrapper->session->reset(info[0].As<v8::Object>());
  }

  static inline Nan::Persistent<v8::Function> &constructor() {
    static Nan::Persistent<v8::Function> my_constructor;
    return my_constructor;
  }

private:
  std::unique_ptr<Session> session;
};

#endif
