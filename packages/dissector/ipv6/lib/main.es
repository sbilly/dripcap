import {
  Session
} from 'dripcap';

export default class IPv6 {
  activate() {
    Session.registerDissector(`${__dirname}/ipv6.es`);
    Session.registerFilterHints('ipv6', [
      {filter: 'ipv6',                description: 'IPv6'},
      {filter: 'ipv6.version',        description: 'Version'},
      {filter: 'ipv6.trafficClass',   description: 'Traffic Class'},
      {filter: 'ipv6.flowLevel',      description: 'Flow Label'},
      {filter: 'ipv6.payloadLength',  description: 'Payload Length'},
      {filter: 'ipv6.hopLimit',       description: 'Hop Limit'},
      {filter: 'ipv6.src',            description: 'Source IP Address'},
      {filter: 'ipv6.dst',            description: 'Destination IP Address'},
      {filter: 'ipv6.protocol',       description: 'Protocol'},
      {filter: 'ipv6.payload',        description: 'Payload'},
      {filter: 'ipv6.payload.length', description: 'Payload Length'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/ipv6.es`);
    Session.unregisterFilterHints('ipv6');
  }
}
