import { remote, clipboard } from 'electron';
let { MenuItem } = remote;
let { dialog } = remote;
import fs from 'fs';
import notifier from 'node-notifier';
import { Menu, Package, PubSub, Session, Layout } from 'dripcap';

export default class PacketView {
  async activate() {
    Layout.require(__dirname + '/../tag/packet-view.tag');
    let layout = {
      center: {
        tag: 'packet-view'
      },
      name: 'Packet',
      id: 'packet-view'
    };
    Layout.container('drip-tab-top').append(layout);
  }

  async deactivate() {
    Layout.container('drip-tab-top').remove('packet-view');
    Layout.unregister('packet-view');
    PubSub.removeHolder(this);
  }
}
