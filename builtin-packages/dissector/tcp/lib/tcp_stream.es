import {Layer, Value, StreamChunk} from 'dripcap';

export default class Dissector {
  static get namespaces() {
    return [/::Ethernet::\w+::<TCP>/];
  }

  constructor() {
    this.seq = -1;
    this.length = 0;
  }

  analyze(packet, parentLayer, chunk) {

    if (parentLayer.payload.length > 0) {
      let stream = {
        namespace: chunk.namespace.replace('<TCP>', 'TCP'),
        id: chunk.id,
        layer: parentLayer,
        attrs: {}
      };
      let payload = chunk.attrs.payload.data;
      let seq = chunk.attrs.seq.data;

      if (this.seq < 0) {
        this.length += payload.length;
        stream.attrs.payload = payload;
      } else {
        let start = this.seq + this.length;
        let length = payload.length;
        if (start > seq) {
          length -= (start - seq);
        }
        this.length += length;
        stream.attrs.payload = payload;
      }
      this.seq = seq;
      return new StreamChunk(stream);
    }

  }
};
