#include "item_value.hpp"
#include "buffer.hpp"
#include "large_buffer.hpp"
#include "session_large_buffer_wrapper.hpp"
#include <memory>
#include <nan.h>
#include <node_buffer.h>
#include <v8pp/class.hpp>
#include <v8pp/json.hpp>

class ItemValue::Private {
public:
  BaseType base = NUL;
  double num;
  std::string str;
  std::unique_ptr<Buffer> buf;
  std::unique_ptr<LargeBuffer> lbuf;
  std::string type;
};

ItemValue::ItemValue() : d(new Private()) {}

ItemValue::ItemValue(const v8::FunctionCallbackInfo<v8::Value> &args)
    : ItemValue(args[0]) {
  v8::Isolate *isolate = v8::Isolate::GetCurrent();
  d->type = v8pp::from_v8<std::string>(isolate, args[1], "");
}

ItemValue::ItemValue(v8::Local<v8::Value> val) : ItemValue() {
  v8::Isolate *isolate = v8::Isolate::GetCurrent();
  if (!val.IsEmpty()) {
    if (val->IsNumber()) {
      d->num = val->NumberValue();
      d->base = NUMBER;
    } else if (val->IsBoolean()) {
      d->num = val->BooleanValue();
      d->base = BOOLEAN;
    } else if (val->IsString()) {
      d->str = v8pp::from_v8<std::string>(isolate, val, "");
      d->base = STRING;
    } else if (val->IsDate()) {
      d->num = val.As<v8::Date>()->ValueOf();
      d->base = DATE;
    } else if (val->IsObject()) {
      if (Buffer *buffer = v8pp::class_<Buffer>::unwrap_object(isolate, val)) {
        d->buf = buffer->slice();
        d->buf->freeze();
        d->base = BUFFER;
      } else if (LargeBuffer *buffer =
                     v8pp::class_<LargeBuffer>::unwrap_object(isolate, val)) {
        d->lbuf.reset(new LargeBuffer(*buffer));
        d->base = LARGE_BUFFER;
      } else {
        d->str = v8pp::json_str(isolate, val);
        d->base = JSON;
      }
    }
  }
}

ItemValue::ItemValue(const ItemValue &value) : ItemValue() { *this = value; }

ItemValue &ItemValue::operator=(const ItemValue &other) {
  if (&other == this)
    return *this;
  d->base = other.d->base;
  d->num = other.d->num;
  d->str = other.d->str;
  if (other.d->buf) {
    d->buf = other.d->buf->slice();
    d->buf->freeze();
  } else if (other.d->lbuf) {
    d->lbuf.reset(new LargeBuffer(*other.d->lbuf));
  }
  d->type = other.d->type;
  return *this;
}

ItemValue::~ItemValue() {}

v8::Local<v8::Value> ItemValue::data() const {
  v8::Isolate *isolate = v8::Isolate::GetCurrent();
  v8::Local<v8::Value> val = v8::Null(isolate);
  switch (d->base) {
  case NUMBER:
    val = v8pp::to_v8(isolate, d->num);
    break;
  case BOOLEAN:
    val = v8pp::to_v8(isolate, static_cast<bool>(d->num));
    break;
  case STRING:
    val = v8pp::to_v8(isolate, d->str);
    break;
  case DATE:
    val = v8::Date::New(isolate, d->num);
    break;
  case BUFFER:
    if (d->buf) {
      if (isolate->GetData(1)) { // node.js
        val = node::Buffer::New(isolate, const_cast<char *>(d->buf->data()),
                                d->buf->length(),
                                [](char *data, void *hint) {
                                  delete static_cast<Buffer *>(hint);
                                },
                                d->buf->slice().release())
                  .ToLocalChecked();
      } else { // dissector
        val = v8pp::class_<Buffer>::import_external(isolate,
                                                    d->buf->slice().release());
      }
    }
    break;
  case LARGE_BUFFER:
    if (isolate->GetData(1)) { // node.js
      val = SessionLargeBufferWrapper::create(*d->lbuf);
    } else { // dissector
      val = v8pp::class_<LargeBuffer>::import_external(
          isolate, new LargeBuffer(*d->lbuf));
    }
    break;
  case JSON:
    val = v8pp::json_parse(isolate, d->str);
    break;
  default:;
  }
  return val;
}

std::string ItemValue::type() const { return d->type; }
