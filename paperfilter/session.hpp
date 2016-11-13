#ifndef SESSION_HPP
#define SESSION_HPP

#include <memory>
#include <string>
#include <v8.h>

class Packet;

class Session {
public:
  Session(v8::Local<v8::Object> option);
  ~Session();
  Session(const Session &) = delete;
  Session &operator=(const Session &) = delete;

  v8::Local<v8::Function> logCallback() const;
  void setLogCallback(const v8::Local<v8::Function> &cb);

  v8::Local<v8::Function> statusCallback() const;
  void setStatusCallback(const v8::Local<v8::Function> &cb);

  void analyze(std::unique_ptr<Packet> pkt);
  void analyze(std::vector<std::unique_ptr<Packet>> packets);
  void filter(const std::string &name, const std::string &filter);
  std::shared_ptr<const Packet> get(uint32_t seq) const;
  std::vector<uint32_t> getFiltered(const std::string &name, uint32_t start,
                                    uint32_t end) const;

  std::string ns() const;

  static bool permission();
  static v8::Local<v8::Array> devices();
  void setInterface(const std::string &ifs);
  std::string networkInterface() const;
  void setPromiscuous(bool promisc);
  bool promiscuous() const;
  void setSnaplen(int len);
  int snaplen() const;
  bool setBPF(const std::string &filter, std::string *error);

  void start();
  void stop();

  void reset(v8::Local<v8::Object> opt);

private:
  class Private;
  Private *d;
};

#endif
