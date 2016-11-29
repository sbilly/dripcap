import { Layout, PubSub } from 'dripcap';
import riot from 'riot';

export default class LogView {
  constructor() {
  }

  async activate() {
    riot.require(__dirname + '/../tag/session-dialog.tag');
    PubSub.on('core:new-live-session', () => {
      let modal = Layout.container('drip-modal');
      modal.set([{
        center: {tag: 'session-dialog', id: "new-live-session-dialog"}
      }], {height: '270px'});
    });
  }

  async deactivate() {
    riot.unregister('session-dialog');
  }
}
