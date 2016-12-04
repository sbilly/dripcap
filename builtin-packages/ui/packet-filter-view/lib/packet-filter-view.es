import { Package, Layout } from 'dripcap';

export default class PacketFilterView {
  async activate() {
    let pkg = await Package.load('packet-list-view');
    Layout.require(__dirname + '/../tag/packet-filter-view.tag');
    Layout.container('packet-list-view').setBottom({
      tag: 'packet-filter-view'
    });
  }

  async deactivate() {
    Layout.container('packet-list-view').setBottom();
    Layout.unregister('packet-filter-view');
    PubSub.removeHolder(this);
  }
}
