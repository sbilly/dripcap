import {Value} from 'dripcap';

export function Enum(table, value) {
  let item = table[value];
  let id = (value in table) ? (typeof item === 'object' ? item.id : item) : 'Unknown';
  let val = {};
  val[id] = true;
  val._value = value;
  val._name = (typeof item === 'object' ? item.name : item);
  return new Value(val, 'dripcap/enum');
}

export function Flags(table, value) {
  let val = {};
  let nameTable = {};
  for (let name in table) {
    let item = table[name];
    nameTable[name] = (typeof item === 'object' ? item.name : name);
    val[name] = !!((typeof item === 'object' ? item.value : item) & value);
  }
  val._value = value;
  val._name = nameTable;
  return new Value(val, 'dripcap/flags');
}

export default function () {}
