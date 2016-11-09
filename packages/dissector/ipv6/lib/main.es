import {
  Session
} from 'dripcap';

export default class IPv6 {
  activate() {
    Session.registerDissector(`${__dirname}/ipv6.es`);
    Session.registerFilterHints('ipv6', []);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/ipv6.es`);
    Session.unregisterFilterHints('ipv6');
  }
}
