#ifndef STREAM_DISSECTOR_THREAD_HPP
#define STREAM_DISSECTOR_THREAD_HPP

#include "dissector.hpp"
#include <functional>
#include <memory>
#include <string>
#include <vector>

class StreamChunk;
class Layer;
struct LogMessage;

class StreamDissectorThread {
public:
  struct Context {
    std::vector<Dissector> dissectors;
    std::function<void(const LogMessage &)> logCb;
    std::function<void(std::vector<std::unique_ptr<StreamChunk>>)> streamsCb;
    std::function<void(std::vector<std::unique_ptr<Layer>>)> vpLayersCb;
  };

public:
  StreamDissectorThread(const std::shared_ptr<Context> &ctx);
  ~StreamDissectorThread();
  StreamDissectorThread(const StreamDissectorThread &) = delete;
  StreamDissectorThread &operator=(const StreamDissectorThread &) = delete;
  void insert(std::unique_ptr<StreamChunk> chunk);
  void clearStream(const std::string &ns, const std::string &id);
  uint32_t queueSize() const;

private:
  class Private;
  std::unique_ptr<Private> d;
};

#endif
