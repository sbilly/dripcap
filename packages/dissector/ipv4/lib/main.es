import {
  Session
} from 'dripcap';

export default class IPv4 {
  activate() {
    Session.registerDissector(`${__dirname}/ipv4.es`);
    Session.registerFilterHints('ipv4', []);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/ipv4.es`);
    Session.unregisterFilterHints('ipv4');
  }
}
