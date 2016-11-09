import {
  Session
} from 'dripcap';

export default class TCP {
  activate() {
    Session.registerStreamDissector(`${__dirname}/http_stream`);
    Session.registerFilterHints('http', [
      {filter: 'http',         description: 'HTTP'},
      {filter: 'http.method',  description: 'Method'},
      {filter: 'http.path',    description: 'Path'},
      {filter: 'http.version', description: 'Version'},
      {filter: 'http.method == "GET"'},
    ]);
  }

  deactivate() {
    Session.unregisterStreamDissector(`${__dirname}/http_stream`);
    Session.unregisterFilterHints('http');
  }
}
