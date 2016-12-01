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
    tab.append({center:{tag: 'log-view'}, bottom: {tag: 'log-view-filter'}, name: 'Log'});

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
/*
    Action.on('log-view:toggle', () => {
      if (this.active) {
        pkg.root.panel.bottom('log-view');
      } else {
        pkg.root.panel.bottom('log-view', this.base, $('<i class="fa fa-file-text"> Log</i>'));
      }
      this.active = !this.active;
      this.config.set('visible', this.active);
    });

    PubSub.sub('core:log', (log) => {
      let textClass = `text-${log.level}`;
      let hours = ('0' + log.timestamp.getHours()).slice(-2);
      let minutes = ('0' + log.timestamp.getMinutes()).slice(-2);
      let seconds = ('0' + log.timestamp.getSeconds()).slice(-2);
      log.date = `${hours}:${minutes}:${seconds}`;
      this.view.logs.push(log);
      this.view.update();
    });
*/
    //Logger.info('log-view loaded');
  }

  async deactivate() {
    Layout.unregister('log-view');
  }
}
