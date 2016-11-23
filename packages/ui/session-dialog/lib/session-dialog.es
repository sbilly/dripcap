import $ from 'jquery';
import riot from 'riot';
import Component from 'dripcap-core/component';
import {
  remote
} from 'electron';
let {
  MenuItem
} = remote;
import {
  KeyBind,
  Menu,
  Package,
  Action,
  PubSub,
  Session
} from 'dripcap-core';

export default class SessionDialog {
  async activate() {
    KeyBind.bind('command+n', '!menu', 'core:new-session');

    this.captureMenu = function(menu, e) {
      let left;
      let action = name => () => Action.emit(name);
      let capturing = (left = PubSub.get('core:capturing-status')) != null ? left.capturing : false;
      menu.append(new MenuItem({
        label: 'New Session',
        accelerator: KeyBind.get('!menu', 'core:new-session'),
        click: action('core:new-session')
      }));
      menu.append(new MenuItem({
        type: 'separator'
      }));
      menu.append(new MenuItem({
        label: 'Start',
        enabled: !capturing,
        click: action('core:start-sessions')
      }));
      menu.append(new MenuItem({
        label: 'Stop',
        enabled: capturing,
        click: action('core:stop-sessions')
      }));
      return menu;
    };

    Menu.registerMain('Capture', this.captureMenu);

    let capturing = null;
    PubSub.sub('core:capturing-status', (stat) => {
      if (capturing !== stat.capturing) {
        Menu.updateMainMenu();
        capturing = stat.capturing;
      }
    });

    this.comp = await Component.create(`${__dirname}/../tag/*.tag`);
    await Package.load('main-view');
    await Package.load('modal-dialog');

    $(() => {
      let n = $('<div>').addClass('container').appendTo($('body'));
      this.view = riot.mount(n[0], 'session-dialog')[0];

      KeyBind.bind('enter', '[riot-tag=session-dialog] .content', () => {
        return $(this.view.tags['modal-dialog'].start).click();
      });

      Session.getInterfaceList().then(list => {
        this.view.setInterfaceList(list);
        this.view.update();
      });

      Action.on('core:new-session', () => {
        this.view.show();
        this.view.update();
        Session.getInterfaceList().then(list => {
          this.view.setInterfaceList(list);
          this.view.update();
        });
      });
    });
  }

  deactivate() {
    Menu.unregisterMain('Capture', this.captureMenu);
    KeyBind.unbind('command+n', '!menu', 'core:new-session');
    KeyBind.unbind('enter', '[riot-tag=session-dialog] .content');
    this.view.unmount();
    this.comp.destroy();
  }
}
