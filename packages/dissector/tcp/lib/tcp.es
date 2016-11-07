import {Layer, Item, Value, StreamChunk} from 'dripcap';
import {Flags, Enum} from 'dripcap/utils';
import {IPv4Host} from 'dripcap/ipv4';
import {IPv6Host} from 'dripcap/ipv6';

export default class Dissector {
  static get namespaces() {
    return [/::Ethernet::\w+::<TCP>/];
  }

  analyze(packet, parentLayer) {
    let layer = {
      items: [],
      attrs: {}
    };
    layer.namespace = parentLayer.namespace.replace('<TCP>', 'TCP');
    layer.name = 'TCP';
    layer.id = 'tcp';

    let source = parentLayer.payload.readUInt16BE(0);
    layer.items.push({
      name: 'Source port',
      id: 'src',
      range: '0:2'
    });

    let destination = parentLayer.payload.readUInt16BE(2);
    layer.items.push({
      name: 'Destination port',
      id: 'dst',
      range: '2:4'
    });

    let srcAddr = parentLayer.attrs.src;
    let dstAddr = parentLayer.attrs.dst;
    if (srcAddr.type === 'dripcap/ipv4/addr') {
      layer.attrs.src = IPv4Host(srcAddr.data, source);
      layer.attrs.dst = IPv4Host(dstAddr.data, destination);
    } else if (srcAddr.type === 'dripcap/ipv6/addr') {
      layer.attrs.src = IPv6Host(srcAddr.data, source);
      layer.attrs.dst = IPv6Host(dstAddr.data, destination);
    }

    let seq = parentLayer.payload.readUInt32BE(4);
    layer.items.push({
      name: 'Sequence number',
      id: 'seq',
      range: '4:8'
    });
    layer.attrs.seq = seq;

    let ack = parentLayer.payload.readUInt32BE(8);
    layer.items.push({
      name: 'Acknowledgment number',
      id: 'ack',
      range: '8:12'
    });
    layer.attrs.ack = ack;

    let dataOffset = parentLayer.payload.readUInt8(12) >> 4;
    layer.items.push({
      name: 'Data offset',
      id: 'dataOffset',
      range: '12:13'
    });
    layer.attrs.dataOffset = dataOffset;

    let table = {
      'NS': 0x1 << 8,
      'CWR': 0x1 << 7,
      'ECE': 0x1 << 6,
      'URG': 0x1 << 5,
      'ACK': 0x1 << 4,
      'PSH': 0x1 << 3,
      'RST': 0x1 << 2,
      'SYN': 0x1 << 1,
      'FIN': 0x1 << 0,
    };

    let flags = Flags(table, parentLayer.payload.readUInt8(13) |
      ((parentLayer.payload.readUInt8(12) & 0x1) << 8));

    layer.items.push({
      name: 'Flags',
      id: 'flags',
      data: '12:14',
      items: [
        {
          name: 'NS',
          id: 'NS',
          range: '12:13'
        },
        {
          name: 'CWR',
          id: 'CWR',
          range: '13:14'
        },
        {
          name: 'ECE',
          id: 'ECE',
          range: '13:14'
        },
        {
          name: 'URG',
          id: 'URG',
          range: '13:14'
        },
        {
          name: 'ACK',
          id: 'ACK',
          range: '13:14'
        },
        {
          name: 'PSH',
          id: 'PSH',
          range: '13:14'
        },
        {
          name: 'RST',
          id: 'RST',
          range: '13:14'
        },
        {
          name: 'SYN',
          id: 'SYN',
          range: '13:14'
        },
        {
          name: 'FIN',
          id: 'FIN',
          range: '13:14'
        }
      ]
    });
    layer.attrs.flags = flags;

    let window = parentLayer.payload.readUInt16BE(14);
    layer.items.push({
      name: 'Window size',
      id: 'window',
      range: '14:16'
    });
    layer.attrs.window = window;

    let checksum = parentLayer.payload.readUInt16BE(16);
    layer.items.push({
      name: 'Checksum',
      id: 'checksum',
      range: '16:18'
    });
    layer.attrs.checksum = checksum;

    let urgent = parentLayer.payload.readUInt16BE(18);
    layer.items.push({
      name: 'Urgent pointer',
      id: 'urgent',
      range: '18:20'
    })
    layer.attrs.urgent = urgent;

    let optionDataOffset = dataOffset * 4;
    let optionItems = [];
    let option = {
      name: 'Options',
      range: '20:' + optionDataOffset,
      items: []
    };

    let optionOffset = 20;

    while (optionDataOffset > optionOffset) {
      switch (parentLayer.payload[optionOffset]) {
        case 0:
          optionOffset = optionDataOffset;
          break;

        case 1:
          option.items.push({
            name: 'NOP',
            range: `${optionOffset}:${optionOffset + 1}`
          });
          optionOffset++;
          break;

        case 2:
          optionItems.push('Maximum segment size');
          option.items.push({
            name: 'Maximum segment size',
            value: parentLayer.payload.readUInt16BE(optionOffset + 2),
            range: `${optionOffset}:${optionOffset + 4}`
          });
          optionOffset += 4;
          break;

        case 3:
          optionItems.push('Window scale');
          option.items.push({
            name: 'Window scale',
            value: parentLayer.payload.readUInt8(optionOffset + 2),
            range: `${optionOffset}:${optionOffset + 3}`
          });
          optionOffset += 3;
          break;

        case 4:
          optionItems.push('Selective ACK permitted');
          option.items.push({
            name: 'Selective ACK permitted',
            range: `${optionOffset}:${optionOffset + 2}`
          });
          optionOffset += 2;
          break;

        // TODO: https://tools.ietf.org/html/rfc2018
        case 5:
          let length = parentLayer.payload.readUInt8(optionOffset + 1);
          optionItems.push('Selective ACK');
          option.items.push({
            name: 'Selective ACK',
            value: parentLayer.payload.slice(optionOffset + 2, optionOffset + length),
            data: `${optionOffset}:${optionOffset + length}`
          });

          optionOffset += length;
          break;

        case 8:
          let mt = parentLayer.payload.readUInt32BE(optionOffset + 2);
          let et = parentLayer.payload.readUInt32BE(optionOffset + 2);
          optionItems.push('Timestamps');
          option.items.push({
            name: 'Timestamps',
            value: `${mt} - ${et}`,
            range: `${optionOffset}:${optionOffset + 10}`,
            items: [{
              name: 'My timestamp',
              value: mt,
              range: `${optionOffset + 2}:${optionOffset + 6}`
            }, {
              name: 'Echo reply timestamp',
              value: et,
              range: `${optionOffset + 6}:${optionOffset + 10}`
            }]
          });
          optionOffset += 10;
          break;

        default:
          throw new Error('unknown option');
      }
    }

    option.value = optionItems.join(',');
    layer.items.push(option);

    layer.range = optionDataOffset + ':';
    layer.payload = parentLayer.payload.slice(optionDataOffset);
    layer.items.push({
      name: 'Payload',
      value: layer.payload,
      range: optionDataOffset + ':'
    });

    layer.summary = `${layer.attrs.src.data} -> ${layer.attrs.dst.data} seq:${seq} ack:${ack}`;

    let id = layer.attrs.src.data + '/' + layer.attrs.dst.data;
    let chunk = {
      namespace: parentLayer.namespace,
      id: id,
      layer: layer,
      attrs: {
        payload: layer.payload,
        seq: seq
      }
    };

    if (flags.data['FIN'] && flags.data['ACK']) {
      chunk.end = true;
    }

    return [new Layer(layer), new StreamChunk(chunk)];
  }
};
