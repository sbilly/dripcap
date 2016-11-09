import {
  Session
} from 'dripcap';

export default class TCP {
  activate() {
    Session.registerDissector(`${__dirname}/tcp.es`);
    Session.registerStreamDissector(`${__dirname}/tcp_stream.es`);
    Session.registerFilterHints('tcp', []);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/tcp.es`);
    Session.unregisterStreamDissector(`${__dirname}/tcp_stream.es`);
    Session.unregisterFilterHints('tcp');
  }
}
