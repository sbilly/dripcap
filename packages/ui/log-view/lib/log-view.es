import $ from 'jquery';
import riot from 'riot';
import Component from 'dripcap-core/component';
import Panel from 'dripcap-core/panel';
import {
  Package,
  Menu,
  PubSub,
  Config,
  Logger,
  Action
} from 'dripcap-core';
import {
  remote
} from 'electron';
let {
  MenuItem,
  app
} = remote;

export default class LogView {
  constructor(pkg) {
    this.config = pkg.config;
  }

  async activate() {
    this.comp = await Component.create(`${__dirname}/../tag/*.tag`);
    let pkg = await Package.load('main-view');
    this.base = $('<div class="wrapper" />').attr('tabIndex', '0');
    this.view = riot.mount(this.base[0], 'log-view')[0];
    this.list = $(this.view.root).find('ul');

    this.active = this.config.get('visible', false);
    if (this.active) {
      pkg.root.panel.bottom('log-view', this.base, $('<i class="fa fa-file-text"> Log</i>'));
    }

    this.toggleMenu = (menu, e) => {
      menu.append(new MenuItem({
        label: 'Toggle Log Panel',
        type: 'checkbox',
        checked: this.active,
        click: () => {
          Action.emit('log-view:toggle');
        }
      }));
      return menu;
    };

    if (process.platform === 'darwin') {
      Menu.registerMain(app.getName(), this.toggleMenu);
    } else {
      Menu.registerMain('Developer', this.toggleMenu);
    }

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

    Logger.info('log-view loaded');
  }

  async deactivate() {
    let pkg = await Package.load('main-view');
    pkg.root.panel.bottom('log-view');
    this.view.unmount();
    this.comp.destroy();
    if (process.platform === 'darwin') {
      Menu.unregisterMain(app.getName(), this.toggleMenu);
    } else {
      Menu.unregisterMain('Developer', this.toggleMenu);
    }
  }
}
