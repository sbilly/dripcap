import { Layout, PubSub } from 'dripcap';
import riot from 'riot';

export default class LogView {
  constructor() {
  }

  async activate() {
    riot.require(__dirname + '/../tag/log-view.tag');
    PubSub.on('core:new-live-session', () => {
      let modal = Layout.container('drip-modal');
      modal.set([{
        center: {tag: 'log-view', id: "new-live-session-view"}
      }]);
    });
  }

  async deactivate() {
    riot.unregister('log-view');
  }
}
