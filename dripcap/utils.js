import {Value} from 'dripcap';

export function Enum(table, value) {
  let name = (value in table) ? table[value] : 'Unknown';
  let val = {};
  val[name] = true;
  val._value = value;
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
