import { Session } from 'dripcap';

export default class ARP {
  activate() {
    Session.registerDissector(`${__dirname}/arp.es`);
    Session.registerFilterHints('arp', [
      {filter: 'arp',           description: 'ARP'},
      {filter: 'arp.htype',     description: 'Hardware type'},
      {filter: 'arp.ptype',     description: 'Protocol type'},
      {filter: 'arp.hlen',      description: 'Hardware length'},
      {filter: 'arp.plen',      description: 'Protocol length'},
      {filter: 'arp.operation', description: 'Operation'},
      {filter: 'arp.sha',       description: 'Sender hardware address'},
      {filter: 'arp.spa',       description: 'Sender protocol address'},
      {filter: 'arp.tha',       description: 'Target hardware address'},
      {filter: 'arp.tpa',       description: 'Target protocol address'}
    ]);
  }

  deactivate() {
    Session.unregisterDissector(`${__dirname}/arp.es`);
    Session.unregisterFilterHints('arp');
  }
}
