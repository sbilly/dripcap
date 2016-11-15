#include "item.hpp"
#include "item_value.hpp"
#include <v8pp/class.hpp>
#include <v8pp/object.hpp>
#include <vector>

using namespace v8;

Item::Item(const v8::FunctionCallbackInfo<v8::Value> &args) : Item(args[0]) {}

Item::Item(v8::Local<v8::Value> value) {
  Isolate *isolate = Isolate::GetCurrent();
  if (!value.IsEmpty() && value->IsObject()) {
    v8::Local<v8::Object> obj = value.As<v8::Object>();
    v8pp::get_option(isolate, obj, "name", name_);
    v8pp::get_option(isolate, obj, "id", id_);
    v8pp::get_option(isolate, obj, "range", range_);

    v8::Local<v8::Value> value;
    if (v8pp::get_option(isolate, obj, "value", value)) {
      if (ItemValue *iv =
              v8pp::class_<ItemValue>::unwrap_object(isolate, value)) {
        value_ = *iv;
      } else {
        value_ = ItemValue(value);
      }
    }

    v8::Local<v8::Array> items;
    if (v8pp::get_option(isolate, obj, "items", items)) {
      for (uint32_t i = 0; i < items->Length(); ++i) {
        v8::Local<v8::Value> item = items->Get(i);
        if (item->IsObject())
          addItem(item.As<v8::Object>());
      }
    }

    v8::Local<v8::Object> attrs;
    if (v8pp::get_option(isolate, obj, "attrs", attrs)) {
      v8::Local<v8::Array> keys = attrs->GetPropertyNames();
      for (uint32_t i = 0; i < keys->Length(); ++i) {
        v8::Local<v8::Value> key = keys->Get(i);
        const std::string &keyStr =
            v8pp::from_v8<std::string>(isolate, key, "");
        if (!keyStr.empty()) {
          setAttr(keyStr, attrs->Get(key));
        }
      }
    }
  }
}

Item::~Item() {}

std::string Item::name() const { return name_; }

void Item::setName(const std::string &name) { name_ = name; }

std::string Item::id() const { return id_; }

void Item::setId(const std::string &id) { id_ = id; }

std::string Item::range() const { return range_; }

void Item::setRange(const std::string &range) { range_ = range; }

v8::Local<v8::Object> Item::valueObject() const {
  Isolate *isolate = Isolate::GetCurrent();
  return v8pp::class_<ItemValue>::import_external(isolate,
                                                  new ItemValue(value_));
}

ItemValue Item::value() const { return value_; }

void Item::setValue(v8::Local<v8::Object> value) {
  Isolate *isolate = Isolate::GetCurrent();
  if (ItemValue *iv = v8pp::class_<ItemValue>::unwrap_object(isolate, value)) {
    value_ = *iv;
  }
}

std::vector<std::shared_ptr<Item>> Item::items() const { return items_; }

void Item::addItem(v8::Local<v8::Object> obj) {
  Isolate *isolate = Isolate::GetCurrent();
  if (Item *item = v8pp::class_<Item>::unwrap_object(isolate, obj)) {
    items_.emplace_back(std::make_shared<Item>(*item));
  } else if (obj->IsObject()) {
    items_.emplace_back(std::make_shared<Item>(obj));
  }
}

void Item::setAttr(const std::string &name, v8::Local<v8::Value> obj) {
  Isolate *isolate = Isolate::GetCurrent();
  if (ItemValue *item = v8pp::class_<ItemValue>::unwrap_object(isolate, obj)) {
    attrs_.emplace(name, *item);
  } else {
    attrs_.emplace(name, ItemValue(obj));
  }
}

std::unordered_map<std::string, ItemValue> Item::attrs() const {
  return attrs_;
}
