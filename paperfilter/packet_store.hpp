#ifndef PACKET_STORE_HPP
#define PACKET_STORE_HPP

#include <functional>
#include <memory>
#include <vector>

class Packet;

class PacketStore {
public:
  PacketStore();
  ~PacketStore();
  PacketStore(const PacketStore &) = delete;
  PacketStore &operator=(const PacketStore &) = delete;
  void insert(const std::vector<std::shared_ptr<Packet>> &packets);
  std::vector<std::shared_ptr<Packet>> get(uint32_t start, uint32_t end) const;
  std::shared_ptr<Packet> get(uint32_t seq) const;
  uint32_t maxSeq() const;
  int addHandler(const std::function<void(uint32_t)> &cb);
  void removeHandler(int id);

private:
  class Private;
  std::unique_ptr<Private> d;
};

#endif
