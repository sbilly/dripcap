import {
  Session
} from 'dripcap';

export default class UDP {
  activate() {
    Session.registerDissector(`${__dirname}/udp`);
    Session.registerFilterHints('udp', [
      {filter: 'udp',                description: 'UDP'},
      {filter: 'udp.srcPort',        description: 'Source port'},
      {filter: 'udp.dstPort',        description: 'Destination port'},
      {filter: 'udp.src',            description: 'Source'},
      {filter: 'udp.dst',            description: 'Destination'},
      {filter: 'udp.len',            description: 'Length'},
      {filter: 'udp.checksum',       description: 'Checksum'},
      {filter: 'udp.payload',        description: 'Payload'},
      {filter: 'udp.payload.length', description: 'Payload Length'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/udp`);
    Session.unregisterFilterHints('udp');
  }
}
