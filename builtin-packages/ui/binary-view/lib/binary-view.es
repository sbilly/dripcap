import { Session, Package, PubSub, Layout } from 'dripcap';

export default class BinaryView {
  async activate() {
    Layout.require(__dirname + '/../tag/binary-view.tag');
    let layout = {
      center: {
        tag: 'binary-view'
      },
      name: 'Binary',
      id: 'binary-view'
    };
    Layout.container('drip-tab-bottom').append(layout);
  }

  async deactivate() {
    Layout.container('drip-tab-bottom').remove('binary-view');
    Layout.unregister('binary-view');
    PubSub.removeHolder(this);
  }
}
