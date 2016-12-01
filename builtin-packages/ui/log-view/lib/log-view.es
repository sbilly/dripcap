import { Package, Menu, PubSub, Config, Logger, Layout } from 'dripcap';
import { remote } from 'electron';
let { MenuItem, app } = remote;

export default class LogView {
  constructor(pkg) {
    this.config = pkg.config;
  }

  async activate() {
    this.active = this.config.get('visible', false);
    Layout.require(__dirname + '/../tag/log-view.tag');
    let tab = Layout.container('drip-tab-bottom');
    let layout = {center:{tag: 'log-view'}, bottom: {tag: 'log-view-filter'}, name: 'Log', id: 'log-view'};

    if (this.active) {
      tab.append(layout);
    }

    this.toggleMenu = (menu, e) => {
      menu.append(new MenuItem({
        label: 'Toggle Log Panel',
        type: 'checkbox',
        checked: this.active,
        click: () => {
          PubSub.emit('log-view:toggle');
        }
      }));
      return menu;
    };

    if (process.platform === 'darwin') {
      Menu.registerMain(app.getName(), this.toggleMenu);
    } else {
      Menu.registerMain('Developer', this.toggleMenu);
    }

    PubSub.on('log-view:toggle', () => {
      if (this.active) {
        tab.remove('log-view');
      } else {
        tab.append(layout);
      }
      this.active = !this.active;
      this.config.set('visible', this.active);
    });

    Logger.info('log-view loaded');
  }

  async deactivate() {
    Layout.unregister('log-view');
  }
}
