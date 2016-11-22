#ifndef ITEM_VALUE_HPP
#define ITEM_VALUE_HPP

#include <memory>
#include <string>
#include <v8.h>

class Buffer;

class ItemValue {
public:
  enum BaseType {
    NUL,
    NUMBER,
    BOOLEAN,
    STRING,
    DATE,
    BUFFER,
    LARGE_BUFFER,
    JSON
  };

public:
  ItemValue();
  explicit ItemValue(const v8::FunctionCallbackInfo<v8::Value> &args);
  explicit ItemValue(v8::Local<v8::Value> val);
  ItemValue(const ItemValue &value);
  ItemValue &operator=(const ItemValue &);
  ~ItemValue();
  v8::Local<v8::Value> data() const;
  std::string type() const;

private:
  class Private;
  std::unique_ptr<Private> d;
};

#endif
