#include "packet_dispatcher.hpp"
#include "stream_chunk.hpp"
#include "dissector_thread.hpp"
#include "packet.hpp"
#include <mutex>
#include <unordered_map>

class PacketDispatcher::Private {
public:
  Private(const std::shared_ptr<Context> &ctx);

public:
  std::shared_ptr<DissectorSharedContext> dissCtx;
  std::vector<std::unique_ptr<DissectorThread>> dissectorThreads;
  uint32_t packetSeq = 0;
};

PacketDispatcher::Private::Private(const std::shared_ptr<Context> &ctx)
    : dissCtx(std::make_shared<DissectorSharedContext>()) {

  dissCtx->dissectors = ctx->dissectors;
  dissCtx->packetCb = ctx->packetCb;
  dissCtx->streamsCb = ctx->streamsCb;
  dissCtx->logCb = ctx->logCb;
  for (int i = 0; i < ctx->threads; ++i) {
    dissectorThreads.emplace_back(new DissectorThread(dissCtx));
  }
}

PacketDispatcher::PacketDispatcher(const std::shared_ptr<Context> &ctx)
    : d(std::make_shared<Private>(ctx)) {}

PacketDispatcher::~PacketDispatcher() {}

void PacketDispatcher::analyze(std::unique_ptr<Packet> packet) {
  {
    std::lock_guard<std::mutex> lock(d->dissCtx->mutex);
    if (packet->seq() == 0) {
      packet->setSeq(++d->packetSeq);
    }
    d->dissCtx->queue.push(std::move(packet));
  }
  d->dissCtx->cond.notify_all();
}

void PacketDispatcher::analyze(std::vector<std::unique_ptr<Packet>> packets) {
  {
    std::lock_guard<std::mutex> lock(d->dissCtx->mutex);
    for (auto &pkt : packets) {
      if (pkt->seq() == 0) {
        pkt->setSeq(++d->packetSeq);
      }
      d->dissCtx->queue.push(std::move(pkt));
    }
  }
  d->dissCtx->cond.notify_all();
}

uint32_t PacketDispatcher::queueSize() const {
  std::lock_guard<std::mutex> lock(d->dissCtx->mutex);
  return d->dissCtx->queue.size();
}
