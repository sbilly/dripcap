import { Session } from 'dripcap';

export default class IPv4 {
  activate() {
    Session.registerDissector(`${__dirname}/ipv4.es`);
    Session.registerFilterHints('ipv4', [
      {filter: 'ipv4',                     description: 'IPv4'},
      {filter: 'ipv4.version',             description: 'Version'},
      {filter: 'ipv4.headerLength',        description: 'Internet Header Length'},
      {filter: 'ipv4.type',                description: 'Type of service'},
      {filter: 'ipv4.totalLength',         description: 'Total Length'},
      {filter: 'ipv4.id',                  description: 'Identification'},
      {filter: 'ipv4.flags',               description: 'Flags'},
      {filter: 'ipv4.flags.reserved',      description: 'Reserved'},
      {filter: 'ipv4.flags.doNotFragment', description: 'Don\'t Fragment'},
      {filter: 'ipv4.flags.moreFragments', description: 'More Fragments'},
      {filter: 'ipv4.fragmentOffset',      description: 'Fragment Offset'},
      {filter: 'ipv4.ttl',                 description: 'TTL'},
      {filter: 'ipv4.protocol',            description: 'Protocol'},
      {filter: 'ipv4.checksum',            description: 'Header Checksum'},
      {filter: 'ipv4.src',                 description: 'Source IP Address'},
      {filter: 'ipv4.dst',                 description: 'Destination IP Address'},
      {filter: 'ipv4.payload',             description: 'Payload'},
      {filter: 'ipv4.payload.length',      description: 'Payload Length'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/ipv4.es`);
    Session.unregisterFilterHints('ipv4');
  }
}
