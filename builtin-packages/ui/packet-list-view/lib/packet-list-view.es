import fs from 'fs';
import { remote } from 'electron';
const { Menu, MenuItem, dialog } = remote;
import { Session, Package, PubSub, Layout } from 'dripcap';

export default class PacketListView {
  async activate() {
    Layout.require(__dirname + '/../tag/packet-list-view.tag');
    let layout = {
      center: {
        tag: 'packet-list-view'
      },
      name: 'Packets',
      id: 'packet-list-view'
    };
    Layout.container('drip-tab-list').append(layout);
  }

  async deactivate() {
    Layout.container('drip-tab-list').remove('packet-list-view');
    Layout.unregister('packet-list-view');
    PubSub.removeHolder(this);
  }
}
