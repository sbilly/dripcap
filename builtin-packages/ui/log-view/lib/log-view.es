import { Layout } from 'dripcap';
import riot from 'riot';

export default class LogView {
  constructor() {
  }

  async activate() {
    riot.require(__dirname + '/../tag/log-view.tag');

    let modal = Layout.container('drip-modal');
    modal.set([{center: {tag: 'log-view', id: "log-view"}}], {height: '280px'});
  }

  async deactivate() {
    riot.unregister('log-view');
  }
}
