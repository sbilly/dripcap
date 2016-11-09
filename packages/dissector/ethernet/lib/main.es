import {
  Session
} from 'dripcap';

export default class Ethernet {
  activate() {
    Session.registerDissector(`${__dirname}/eth.es`);
    Session.registerFilterHints('eth', [
      {filter: 'eth',     description: 'Ethernet'},
      {filter: 'eth.dst', description: 'Destination'},
      {filter: 'eth.src', description: 'Source'},
      {filter: 'eth.dst.startsWith("00:")'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/eth.es`);
    Session.unregisterFilterHints('eth');
  }
}
