#include "filter.hpp"
#include "layer.hpp"
#include "packet.hpp"
#include "item_value.hpp"
#include <json11.hpp>
#include <nan.h>
#include <v8pp/class.hpp>
#include <v8pp/json.hpp>
#include <v8pp/object.hpp>

FilterFunc makeFilter(const json11::Json &json) {
  v8::Isolate *isolate = v8::Isolate::GetCurrent();

  const std::string &type = json["type"].string_value();

  if (type == "MemberExpression") {
    const json11::Json &property = json["property"];
    const std::string &propertyType = property["type"].string_value();
    FilterFunc propertyFunc;

    if (propertyType == "Identifier") {
      const std::string &name = property["name"].string_value();
      propertyFunc = [isolate, name](Packet *) {
        return v8pp::to_v8(isolate, name);
      };
    } else {
      propertyFunc = makeFilter(property);
    }

    const FilterFunc &objectFunc = makeFilter(json["object"]);

    return FilterFunc([isolate, objectFunc,
                       propertyFunc](Packet *pkt) -> v8::Local<v8::Value> {
      v8::Local<v8::Value> value = objectFunc(pkt);
      v8::Local<v8::Value> property = propertyFunc(pkt);
      v8::Local<v8::Value> result = v8::Null(isolate);

      const std::string &name =
          v8pp::from_v8<std::string>(isolate, property, "");
      if (name.empty())
        return result;

      if (const Layer *layer =
              v8pp::class_<Layer>::unwrap_object(isolate, value)) {
        const std::unordered_map<std::string, ItemValue> &attrs =
            layer->attrs();
        const auto it = attrs.find(name);
        if (it != attrs.end()) {
          result = it->second.data();
        }
      } else {
        if (value->IsString()) {
          value = v8::StringObject::New(value.As<v8::String>());
        }
        if (value->IsObject()) {
          v8::Local<v8::Object> object = value.As<v8::Object>();
          v8::Local<v8::Value> key = v8pp::to_v8(isolate, name);
          if (object->Has(key)) {
            result = object->Get(key);
          }
        }
      }

      if (!result.IsEmpty() && result->IsObject()) {
        v8::Local<v8::Object> resultObj = result.As<v8::Object>();
        v8::Local<v8::String> resultKey = v8pp::to_v8(isolate, "__filterValue");
        if (resultObj->Has(resultKey)) {
          return resultObj->Get(resultKey);
        }
      }

      return result;
    });
  } else if (type == "BinaryExpression") {
    const FilterFunc &lf = makeFilter(json["left"]);
    const FilterFunc &rf = makeFilter(json["right"]);
    const std::string &op = json["operator"].string_value();

    if (op == ">") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Boolean::New(isolate, lf(pkt)->NumberValue() >
                                             rf(pkt)->NumberValue());
      });
    } else if (op == "<") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Boolean::New(isolate, lf(pkt)->NumberValue() <
                                             rf(pkt)->NumberValue());
      });
    } else if (op == ">=") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Boolean::New(isolate, lf(pkt)->NumberValue() >=
                                             rf(pkt)->NumberValue());
      });
    } else if (op == "<=") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Boolean::New(isolate, lf(pkt)->NumberValue() <=
                                             rf(pkt)->NumberValue());
      });
    } else if (op == "==") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Boolean::New(isolate, lf(pkt)->Equals(rf(pkt)));
      });
    } else if (op == "!=") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Boolean::New(isolate, !lf(pkt)->Equals(rf(pkt)));
      });
    } else if (op == "+") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->NumberValue() + rf(pkt)->NumberValue());
      });
    } else if (op == "-") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->NumberValue() + rf(pkt)->NumberValue());
      });
    } else if (op == "*") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->NumberValue() + rf(pkt)->NumberValue());
      });
    } else if (op == "/") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->NumberValue() + rf(pkt)->NumberValue());
      });
    } else if (op == "%") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->Int32Value() % rf(pkt)->Int32Value());
      });
    } else if (op == "&") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->Int32Value() & rf(pkt)->Int32Value());
      });
    } else if (op == "|") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->Int32Value() | rf(pkt)->Int32Value());
      });
    } else if (op == "^") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->Int32Value() ^ rf(pkt)->Int32Value());
      });
    } else if (op == ">>") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate,
                               lf(pkt)->Int32Value() >> rf(pkt)->Int32Value());
      });
    } else if (op == "<<") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) {
        return v8::Number::New(isolate, lf(pkt)->Int32Value()
                                            << rf(pkt)->Int32Value());
      });
    }
  } else if (type == "Literal") {
    const json11::Json &regex = json["regex"];
    if (regex.is_object()) {
      const std::string &value = json["value"].string_value();
      return FilterFunc([isolate, value](Packet *pkt) -> v8::Local<v8::Value> {
        Nan::MaybeLocal<Nan::BoundScript> script =
            Nan::CompileScript(v8pp::to_v8(isolate, value));
        if (!script.IsEmpty()) {
          Nan::MaybeLocal<v8::Value> result =
              Nan::RunScript(script.ToLocalChecked());
          if (!result.IsEmpty()) {
            return result.ToLocalChecked();
          }
        }
        return v8::Null(isolate);
      });
    } else {
      const std::string &value = json["value"].dump();
      return FilterFunc([isolate, value](Packet *pkt) -> v8::Local<v8::Value> {
        return v8pp::json_parse(isolate, value);
      });
    }

  } else if (type == "LogicalExpression") {
    const std::string &op = json["operator"].string_value();
    const FilterFunc &lf = makeFilter(json["left"]);
    const FilterFunc &rf = makeFilter(json["right"]);
    if (op == "||") {
      return FilterFunc([isolate, lf, rf](Packet *pkt) -> v8::Local<v8::Value> {
        v8::Local<v8::Value> value = lf(pkt);
        return value->BooleanValue() ? value : rf(pkt);
      });
    } else {
      return FilterFunc([isolate, lf, rf](Packet *pkt) -> v8::Local<v8::Value> {
        v8::Local<v8::Value> value = lf(pkt);
        return !value->BooleanValue() ? value : rf(pkt);
      });
    }
  } else if (type == "UnaryExpression") {
    const FilterFunc &func = makeFilter(json["argument"]);
    const std::string &op = json["operator"].string_value();
    if (op == "+") {
      return FilterFunc([isolate, func](Packet *pkt) -> v8::Local<v8::Value> {
        return v8pp::to_v8(isolate, func(pkt)->NumberValue());
      });
    } else if (op == "-") {
      return FilterFunc([isolate, func](Packet *pkt) -> v8::Local<v8::Value> {
        return v8pp::to_v8(isolate, -func(pkt)->NumberValue());
      });
    } else if (op == "!") {
      return FilterFunc([isolate, func](Packet *pkt) -> v8::Local<v8::Value> {
        return v8pp::to_v8(isolate, !func(pkt)->BooleanValue());
      });
    } else if (op == "~") {
      return FilterFunc([isolate, func](Packet *pkt) -> v8::Local<v8::Value> {
        return v8pp::to_v8(isolate, ~func(pkt)->Int32Value());
      });
    }
  } else if (type == "CallExpression") {
    const FilterFunc &cf = makeFilter(json["callee"]);
    std::vector<FilterFunc> argFuncs;
    for (const json11::Json &item : json["arguments"].array_items()) {
      argFuncs.push_back(makeFilter(item));
    }
    return FilterFunc([isolate, cf,
                       argFuncs](Packet *pkt) -> v8::Local<v8::Value> {
      v8::Local<v8::Value> func = cf(pkt);
      if (func->IsFunction()) {
        std::vector<v8::Local<v8::Value>> args;
        for (const FilterFunc &arg : argFuncs) {
          args.push_back(arg(pkt));
        }
        return func.As<v8::Object>()->CallAsFunction(
            isolate->GetCurrentContext()->Global(), args.size(), args.data());
      }
      return v8::Null(isolate);
    });
  } else if (type == "ConditionalExpression") {
    const FilterFunc &tf = makeFilter(json["test"]);
    const FilterFunc &cf = makeFilter(json["consequent"]);
    const FilterFunc &af = makeFilter(json["alternate"]);
    return FilterFunc(
        [isolate, tf, cf, af](Packet *pkt) -> v8::Local<v8::Value> {
          return tf(pkt)->BooleanValue() ? cf(pkt) : af(pkt);
        });
  } else if (type == "Identifier") {
    const std::string &name = json["name"].string_value();
    return FilterFunc([isolate, name](Packet *pkt) -> v8::Local<v8::Value> {

      v8::Local<v8::Value> key = v8pp::to_v8(isolate, name);
      v8::Local<v8::Object> pktObject =
          v8pp::class_<Packet>::find_object(isolate, pkt);
      if (pktObject.IsEmpty()) {
        pktObject = v8pp::class_<Packet>::reference_external(isolate, pkt);
      }
      if (pktObject->Has(key)) {
        return pktObject->Get(key);
      }

      std::function<std::shared_ptr<Layer>(
          const std::string &name,
          const std::unordered_map<std::string, std::shared_ptr<Layer>> &)>
          findLayer;
      findLayer = [&findLayer](
          const std::string &name,
          const std::unordered_map<std::string, std::shared_ptr<Layer>>
              &layers) {
        for (const auto &pair : layers) {
          if (pair.second->id() == name) {
            return pair.second;
          }
        }
        for (const auto &pair : layers) {
          const std::shared_ptr<Layer> &layer =
              findLayer(name, pair.second->layers());
          if (layer) {
            return layer;
          }
        }
        return std::shared_ptr<Layer>();
      };
      if (const std::shared_ptr<Layer> &layer =
              findLayer(name, pkt->layers())) {
        return v8pp::class_<Layer>::reference_external(isolate, layer.get());
      }
      if (name == "$") {
        return pktObject;
      }
      v8::Local<v8::Object> global = isolate->GetCurrentContext()->Global();
      if (global->Has(key)) {
        return global->Get(key);
      }
      return v8::Null(isolate);
    });
  }

  return FilterFunc([isolate](Packet *) { return v8::Null(isolate); });
}

FilterFunc makeFilter(const std::string &jsonstr) {
  std::string err;
  json11::Json json = json11::Json::parse(jsonstr, err);
  return makeFilter(json);
}
