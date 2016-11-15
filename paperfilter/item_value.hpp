#ifndef ITEM_VALUE_HPP
#define ITEM_VALUE_HPP

#include <memory>
#include <string>
#include <v8.h>
#include "buffer.hpp"
#include "large_buffer.hpp"

class ItemValue {
public:
  enum BaseType { NUL, NUMBER, BOOLEAN, STRING, BUFFER, LARGE_BUFFER, JSON };

public:
  ItemValue() = default;
  explicit ItemValue(const v8::FunctionCallbackInfo<v8::Value> &args);
  explicit ItemValue(const v8::Local<v8::Value> &val);
  ItemValue(const ItemValue &value);
  ItemValue &operator=(const ItemValue &);
  ~ItemValue();
  v8::Local<v8::Value> data() const;
  std::string type() const;

private:
  BaseType base_ = NUL;
  double num_;
  std::string str_;
  std::unique_ptr<Buffer> buf_;
  std::unique_ptr<LargeBuffer> lbuf_;
  std::string type_;
};

#endif
