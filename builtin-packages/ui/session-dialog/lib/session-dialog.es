import { Layout, PubSub } from 'dripcap';
import riot from 'riot';

export default class LogView {
  constructor() {
  }

  async activate() {
    Layout.require(__dirname + '/../tag/session-dialog.tag');
    PubSub.on(this, 'core:new-live-session', () => {
      let modal = Layout.container('drip-modal');
      modal.set([{
        center: {tag: 'session-dialog', id: "new-live-session-dialog"}
      }], {height: '270px'});
    });
  }

  async deactivate() {
    PubSub.removeHolder(this);
    Layout.unregister('session-dialog');
  }
}
