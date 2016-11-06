import {Layer, Item, Value} from 'dripcap';
import {Flags, Enum} from 'dripcap/utils';
import {IPv4Address} from 'dripcap/ipv4';
import {MACAddress} from 'dripcap/mac';

export default class ARPDissector {
  static get namespaces() {
    return ['::Ethernet::<ARP>'];
  }

  analyze(packet, parentLayer) {
    let layer = {
      items: [],
      attrs: {}
    };
    layer.namespace = '::Ethernet::ARP';
    layer.name = 'ARP';
    layer.id = 'arp';

    let htypeNumber = parentLayer.payload.readUInt16BE(0);
    let htype = Enum(hardwareTable, htypeNumber);
    layer.items.push({
      name: 'Hardware type',
      value: htype,
      range: '0:2'
    });
    layer.attrs.htype = htype;

    let ptypeNumber = parentLayer.payload.readUInt16BE(2);
    let ptype = Enum(protocolTable, ptypeNumber);
    layer.items.push({
      name: 'Protocol type',
      value: ptype,
      range: '2:4'
    });
    layer.attrs.ptype = ptype;

    let hlen = parentLayer.payload.readUInt8(4);
    layer.items.push({
      name: 'Hardware length',
      value: hlen,
      range: '4:5'
    });
    layer.attrs.hlen = hlen;

    let plen = parentLayer.payload.readUInt8(5);
    layer.items.push({
      name: 'Protocol length',
      value: plen,
      range: '5:6'
    });
    layer.attrs.plen = plen;

    let operationNumber = parentLayer.payload.readUInt16BE(6);
    let operation = Enum(operationTable, operationNumber);
    let operationName = operationTable[operationNumber];
    layer.items.push({
      name: 'Operation',
      value: operation,
      range: '6:8'
    });
    layer.attrs.operation = operation;

    let sha = MACAddress(parentLayer.payload.slice(8, 14));
    layer.items.push({
      name: 'Sender hardware address',
      value: sha,
      range: '8:14'
    });
    layer.attrs.sha = sha;

    let spa = IPv4Address(parentLayer.payload.slice(14, 18));
    layer.items.push({
      name: 'Sender protocol address',
      value: spa,
      range: '14:18'
    });
    layer.attrs.spa = spa;

    let tha = MACAddress(parentLayer.payload.slice(18, 24));
    layer.items.push({
      name: 'Target hardware address',
      value: tha,
      range: '18:24'
    });
    layer.attrs.tha = tha;

    let tpa = IPv4Address(parentLayer.payload.slice(24, 28));
    layer.items.push({
      name: 'Target protocol address',
      value: tpa,
      range: '24:28'
    });
    layer.attrs.tpa = tpa;

    layer.summary = `[${operationName.toUpperCase()}] ${sha.data}-${spa.data} -> ${tha.data}-${tpa.data}`;

    return new Layer(layer);
  }
}

let hardwareTable = {
  0x1: 'Ethernet'
};

let protocolTable = {
  0x0800: {id: 'ipv4', name: 'IPv4'},
  0x86DD: {id: 'ipv6', name: 'IPv6'}
};

let operationTable = {
  0x1: 'request',
  0x2: 'reply'
};
