import { Session } from 'dripcap';

export default class DNS {
  activate() {
    Session.registerDissector(`${__dirname}/dns.es`);
    Session.registerFilterHints('dns', [
      {filter: 'dns',                description: 'DNS'},
      {filter: 'dns.id',             description: 'ID'},
      {filter: 'dns.qr',             description: 'Query/Response Flag'},
      {filter: 'dns.opcode',         description: 'Operation Code'},
      {filter: 'dns.aa',             description: 'Authoritative Answer Flag'},
      {filter: 'dns.tc',             description: 'Truncation Flag'},
      {filter: 'dns.rd',             description: 'Recursion Desired'},
      {filter: 'dns.ra',             description: 'Recursion Available'},
      {filter: 'dns.rcode',          description: 'Response Code'},
      {filter: 'dns.qdCount',        description: 'Question Count'},
      {filter: 'dns.anCount',        description: 'Answer Record Count'},
      {filter: 'dns.nsCount',        description: 'Authority Record Count'},
      {filter: 'dns.arCount',        description: 'Additional Record Count'},
      {filter: 'dns.payload',        description: 'Payload'},
      {filter: 'dns.payload.length', description: 'Payload Length'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/dns.es`);
    Session.unregisterFilterHints('dns');
  }
}
