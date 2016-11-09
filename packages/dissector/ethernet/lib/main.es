import {
  Session
} from 'dripcap';

export default class Ethernet {
  activate() {
    Session.registerDissector(`${__dirname}/eth`);
    Session.registerFilterHints('eth', [
      {filter: 'eth',                description: 'Ethernet'},
      {filter: 'eth.dst',            description: 'Destination'},
      {filter: 'eth.src',            description: 'Source'},
      {filter: 'eth.len',            description: 'Length'},
      {filter: 'eth.etherType',      description: 'EtherType'},
      {filter: 'eth.payload',        description: 'Payload'},
      {filter: 'eth.payload.length', description: 'Payload Length'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/eth`);
    Session.unregisterFilterHints('eth');
  }
}
