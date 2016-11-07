#ifndef PACKET_DISPATCHER_HPP
#define PACKET_DISPATCHER_HPP

#include "dissector.hpp"
#include <functional>
#include <memory>
#include <vector>
#include <queue>
#include <mutex>
#include <condition_variable>

class StreamChunk;
class Layer;
class Packet;
struct LogMessage;

struct DissectorSharedContext {
  std::vector<Dissector> dissectors;
  std::function<void(const std::shared_ptr<Packet> &)> packetCb;
  std::function<void(uint32_t, std::vector<std::unique_ptr<StreamChunk>>)>
      streamsCb;
  std::function<void(const LogMessage &)> logCb;
  std::queue<std::unique_ptr<Packet>> queue;
  std::mutex mutex;
  std::condition_variable cond;
};

class PacketDispatcher {
public:
  struct Context {
    int threads;
    std::vector<Dissector> dissectors;
    std::function<void(const std::shared_ptr<Packet> &)> packetCb;
    std::function<void(uint32_t, std::vector<std::unique_ptr<StreamChunk>>)>
        streamsCb;
    std::function<void(const LogMessage &)> logCb;
  };

public:
  PacketDispatcher(const std::shared_ptr<Context> &ctx);
  ~PacketDispatcher();
  PacketDispatcher(const PacketDispatcher &) = delete;
  PacketDispatcher &operator=(const PacketDispatcher &) = delete;
  void analyze(std::unique_ptr<Packet> packet);
  uint32_t queueSize() const;

private:
  class Private;
  std::shared_ptr<Private> d;
};

#endif
