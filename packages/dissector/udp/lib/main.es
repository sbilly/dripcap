import {
  Session
} from 'dripcap';

export default class UDP {
  activate() {
    Session.registerDissector(`${__dirname}/udp.es`);
    Session.registerFilterHints('udp', []);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/udp.es`);
    Session.unregisterFilterHints('udp');
  }
}
