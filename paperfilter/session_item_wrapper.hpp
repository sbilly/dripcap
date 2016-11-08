#ifndef SESSION_ITEM_WRAPPER_HPP
#define SESSION_ITEM_WRAPPER_HPP

#include "item.hpp"
#include "session_item_value_wrapper.hpp"
#include <nan.h>
#include <v8pp/class.hpp>

class SessionItemWrapper : public Nan::ObjectWrap {
private:
  SessionItemWrapper(const std::shared_ptr<Item> &item) : item(item) {}
  SessionItemWrapper(const SessionItemWrapper &) = delete;
  SessionItemWrapper &operator=(const SessionItemWrapper &) = delete;

  v8::UniquePersistent<v8::Object> itemsCache;
  v8::UniquePersistent<v8::Object> attrsCache;

public:
  static NAN_MODULE_INIT(Init) {
    v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
    tpl->InstanceTemplate()->SetInternalFieldCount(1);
    tpl->SetClassName(Nan::New("Item").ToLocalChecked());
    v8::Local<v8::ObjectTemplate> otl = tpl->InstanceTemplate();
    Nan::SetAccessor(otl, Nan::New("name").ToLocalChecked(), name);
    Nan::SetAccessor(otl, Nan::New("id").ToLocalChecked(), id);
    Nan::SetAccessor(otl, Nan::New("range").ToLocalChecked(), range);
    Nan::SetAccessor(otl, Nan::New("value").ToLocalChecked(), value);
    Nan::SetAccessor(otl, Nan::New("items").ToLocalChecked(), items);
    Nan::SetAccessor(otl, Nan::New("attrs").ToLocalChecked(), attrs);
    constructor().Reset(Nan::GetFunction(tpl).ToLocalChecked());
  }

  static NAN_METHOD(New) { info.GetReturnValue().Set(info.This()); }

  static inline Nan::Persistent<v8::Function> &constructor() {
    static Nan::Persistent<v8::Function> my_constructor;
    return my_constructor;
  }

  static NAN_GETTER(name) {
    SessionItemWrapper *wrapper =
        ObjectWrap::Unwrap<SessionItemWrapper>(info.Holder());
    info.GetReturnValue().Set(
        v8pp::to_v8(v8::Isolate::GetCurrent(), wrapper->item->name()));
  }

  static NAN_GETTER(id) {
    SessionItemWrapper *wrapper =
        ObjectWrap::Unwrap<SessionItemWrapper>(info.Holder());
    info.GetReturnValue().Set(
        v8pp::to_v8(v8::Isolate::GetCurrent(), wrapper->item->id()));
  }

  static NAN_GETTER(range) {
    SessionItemWrapper *wrapper =
        ObjectWrap::Unwrap<SessionItemWrapper>(info.Holder());
    info.GetReturnValue().Set(
        v8pp::to_v8(v8::Isolate::GetCurrent(), wrapper->item->range()));
  }

  static NAN_GETTER(value) {
    SessionItemWrapper *wrapper =
        ObjectWrap::Unwrap<SessionItemWrapper>(info.Holder());
    info.GetReturnValue().Set(
        SessionItemValueWrapper::create(wrapper->item->value()));
  }

  static NAN_GETTER(items) {
    v8::Isolate *isolate = v8::Isolate::GetCurrent();
    SessionItemWrapper *wrapper =
        ObjectWrap::Unwrap<SessionItemWrapper>(info.Holder());

    v8::Local<v8::Object> obj;

    if (wrapper->itemsCache.IsEmpty()) {
      const auto &items = wrapper->item->items();
      v8::Local<v8::Array> array = v8::Array::New(isolate, items.size());
      for (size_t i = 0; i < items.size(); ++i) {
        array->Set(i, SessionItemWrapper::create(items[i]));
      }
      obj = array;
      wrapper->itemsCache = v8::UniquePersistent<v8::Object>(isolate, obj);
    } else {
      obj = v8::Local<v8::Object>::New(isolate, wrapper->itemsCache);
    }

    info.GetReturnValue().Set(obj);
  }

  static NAN_GETTER(attrs) {
    v8::Isolate *isolate = v8::Isolate::GetCurrent();
    SessionItemWrapper *wrapper =
        ObjectWrap::Unwrap<SessionItemWrapper>(info.Holder());

    v8::Local<v8::Object> obj;

    if (wrapper->attrsCache.IsEmpty()) {
      const auto &attrs = wrapper->item->attrs();
      obj = v8::Object::New(isolate);
      for (const auto &pair : attrs) {
        obj->Set(v8pp::to_v8(isolate, pair.first),
                 SessionItemValueWrapper::create(pair.second));
      }
      wrapper->attrsCache = v8::UniquePersistent<v8::Object>(isolate, obj);
    } else {
      obj = v8::Local<v8::Object>::New(isolate, wrapper->attrsCache);
    }

    info.GetReturnValue().Set(obj);
  }

  static v8::Local<v8::Object> create(const std::shared_ptr<Item> &item) {
    v8::Local<v8::Function> cons = Nan::New(constructor());
    v8::Local<v8::Value> argv[1] = {
        v8::Isolate::GetCurrent()->GetCurrentContext()->Global()};
    v8::Local<v8::Object> obj = cons->NewInstance(1, argv);
    SessionItemWrapper *wrapper = new SessionItemWrapper(item);
    wrapper->Wrap(obj);
    return obj;
  }

private:
  std::shared_ptr<Item> item;
};

#endif
