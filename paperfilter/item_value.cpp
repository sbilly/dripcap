#include "item_value.hpp"
#include "session_large_buffer_wrapper.hpp"
#include <memory>
#include <nan.h>
#include <node_buffer.h>
#include <v8pp/class.hpp>
#include <v8pp/json.hpp>

ItemValue::ItemValue(const v8::FunctionCallbackInfo<v8::Value> &args)
    : ItemValue(args[0]) {
  v8::Isolate *isolate = v8::Isolate::GetCurrent();
  type_ = v8pp::from_v8<std::string>(isolate, args[1], "");
}

ItemValue::ItemValue(const v8::Local<v8::Value> &val) {
  v8::Isolate *isolate = v8::Isolate::GetCurrent();
  if (!val.IsEmpty()) {
    if (val->IsNumber()) {
      num_ = val->NumberValue();
      base_ = NUMBER;
    } else if (val->IsBoolean()) {
      num_ = val->BooleanValue();
      base_ = BOOLEAN;
    } else if (val->IsString()) {
      str_ = v8pp::from_v8<std::string>(isolate, val, "");
      base_ = STRING;
    } else if (val->IsObject()) {
      if (Buffer *buffer = v8pp::class_<Buffer>::unwrap_object(isolate, val)) {
        buf_ = buffer->slice();
        buf_->freeze();
        base_ = BUFFER;
      } else if (LargeBuffer *buffer =
                     v8pp::class_<LargeBuffer>::unwrap_object(isolate, val)) {
        lbuf_.reset(new LargeBuffer(*buffer));
        base_ = LARGE_BUFFER;
      } else {
        str_ = v8pp::json_str(isolate, val);
        base_ = JSON;
      }
    }
  }
}

ItemValue::ItemValue(const ItemValue &value) : ItemValue() { *this = value; }

ItemValue &ItemValue::operator=(const ItemValue &other) {
  if (&other == this)
    return *this;
  base_ = other.base_;
  num_ = other.num_;
  str_ = other.str_;
  if (other.buf_) {
    buf_ = other.buf_->slice();
    buf_->freeze();
  } else if (other.lbuf_) {
    lbuf_.reset(new LargeBuffer(*other.lbuf_));
  }
  type_ = other.type_;
  return *this;
}

ItemValue::~ItemValue() {}

v8::Local<v8::Value> ItemValue::data() const {
  v8::Isolate *isolate = v8::Isolate::GetCurrent();
  v8::Local<v8::Value> val = v8::Null(isolate);
  switch (base_) {
  case NUMBER:
    val = v8pp::to_v8(isolate, num_);
    break;
  case BOOLEAN:
    val = v8pp::to_v8(isolate, static_cast<bool>(num_));
    break;
  case STRING:
    val = v8pp::to_v8(isolate, str_);
    break;
  case BUFFER:
    if (buf_) {
      if (isolate->GetData(1)) { // node.js
        val = node::Buffer::New(isolate, const_cast<char *>(buf_->data()),
                                buf_->length(),
                                [](char *data, void *hint) {
                                  delete static_cast<Buffer *>(hint);
                                },
                                buf_->slice().release())
                  .ToLocalChecked();
      } else { // dissector
        val = v8pp::class_<Buffer>::import_external(isolate,
                                                    buf_->slice().release());
      }
    }
    break;
  case LARGE_BUFFER:
    if (isolate->GetData(1)) { // node.js
      val = SessionLargeBufferWrapper::create(*lbuf_);
    } else { // dissector
      val = v8pp::class_<LargeBuffer>::import_external(isolate,
                                                       new LargeBuffer(*lbuf_));
    }
    break;
  case JSON:
    val = v8pp::json_parse(isolate, str_);
    break;
  default:;
  }
  return val;
}

std::string ItemValue::type() const { return type_; }
