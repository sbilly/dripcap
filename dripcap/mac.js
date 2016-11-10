import {Value} from 'dripcap';

export function MACAddress(buffer) {
  let hex = buffer.toString('hex');
  let val = `${hex[0]}${hex[1]}:${hex[2]}${hex[3]}:${hex[4]}${hex[5]}:${hex[6]}${hex[7]}:${hex[8]}${hex[9]}:${hex[10]}${hex[11]}`;
  return new Value(val, 'dripcap/mac');
}

export default function () {}
