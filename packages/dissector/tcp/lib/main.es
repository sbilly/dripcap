import {
  Session
} from 'dripcap-core';

export default class TCP {
  activate() {
    Session.registerDissector(`${__dirname}/tcp.es`);
    Session.registerStreamDissector(`${__dirname}/tcp_stream.es`);
    Session.registerFilterHints('tcp', [
      {filter: 'tcp',                description: 'TCP'},
      {filter: 'tcp.srcPort',        description: 'Source port'},
      {filter: 'tcp.dstPort',        description: 'Destination port'},
      {filter: 'tcp.src',            description: 'Source'},
      {filter: 'tcp.dst',            description: 'Destination'},
      {filter: 'tcp.seq',            description: 'Sequence number'},
      {filter: 'tcp.ack',            description: 'Acknowledgment number'},
      {filter: 'tcp.dataOffset',     description: 'Data offset'},
      {filter: 'tcp.flags',          description: 'Flags'},
      {filter: 'tcp.flags.NS',       description: 'NS'},
      {filter: 'tcp.flags.CWR',      description: 'CWR'},
      {filter: 'tcp.flags.ECE',      description: 'ECE'},
      {filter: 'tcp.flags.URG',      description: 'URG'},
      {filter: 'tcp.flags.ACK',      description: 'ACK'},
      {filter: 'tcp.flags.PSH',      description: 'PSH'},
      {filter: 'tcp.flags.RST',      description: 'RST'},
      {filter: 'tcp.flags.SYN',      description: 'SYN'},
      {filter: 'tcp.flags.FIN',      description: 'FIN'},
      {filter: 'tcp.window',         description: 'Window size'},
      {filter: 'tcp.checksum',       description: 'Checksum'},
      {filter: 'tcp.urgent',         description: 'Urgent pointer'},
      {filter: 'tcp.payload',        description: 'Payload'},
      {filter: 'tcp.payload.length', description: 'Payload Length'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/tcp.es`);
    Session.unregisterStreamDissector(`${__dirname}/tcp_stream.es`);
    Session.unregisterFilterHints('tcp');
  }
}
