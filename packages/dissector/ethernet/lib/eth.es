import {Layer, Item, Value} from 'dripcap';
import {Enum} from 'dripcap/utils';
import {MACAddress} from 'dripcap/mac';

export default class Dissector {
  static get namespaces() {
    return ['::<Ethernet>'];
  }

  analyze(packet, parentLayer) {
    let layer = {
      items: [],
      attrs: {}
    };
    layer.namespace = '::Ethernet';
    layer.name = 'Ethernet';
    layer.id = 'eth';

    let destination = MACAddress(parentLayer.payload.slice(0, 6));
    layer.items.push({
      name: 'Destination',
      id: 'dst',
      range: '0:6'
    });
    layer.attrs.dst = destination;

    let source = MACAddress(parentLayer.payload.slice(6, 12));
    layer.items.push({
      name: 'Source',
      id: 'src',
      range: '6:12'
    });
    layer.attrs.src = source;

    let protocolName;
    let type = parentLayer.payload.readUInt16BE(12);
    if (type <= 1500) {
      layer.items.push({
        name: 'Length',
        id: 'len',
        range: '12:14'
      });
      layer.attrs.len = type;
    } else {
      let table = {
        0x0800: 'IPv4',
        0x0806: 'ARP',
        0x0842: 'WoL',
        0x809B: 'AppleTalk',
        0x80F3: 'AARP',
        0x86DD: 'IPv6'
      };

      let etherType = Enum(table, type);
      layer.items.push({
        name: 'EtherType',
        id: 'etherType',
        range: '12:14'
      });
      layer.attrs.etherType = etherType;

      protocolName = table[type];
      if (protocolName != null) {
        layer.namespace = `::Ethernet::<${protocolName}>`;
      }
    }

    layer.summary = `${source.data} -> ${destination.data}`;
    if (protocolName != null) {
      layer.summary = `[${protocolName}] ` + layer.summary;
    }

    layer.range = '14:';
    layer.payload = parentLayer.payload.slice(14);
    layer.items.push({
      name: 'Payload',
      value: layer.payload,
      range: '14:'
    });

    return new Layer(layer);
  }
};
