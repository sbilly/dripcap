import $ from 'jquery';
import riot from 'riot';
import Component from 'dripcap-core/component';
import Panel from 'dripcap-core/panel';
import {
  Session,
  Package,
  PubSub
} from 'dripcap-core';

export default class BinaryView {
  async activate() {
    this.comp = await Component.create(`${__dirname}/../tag/*.tag`);
    let pkg = await Package.load('main-view');

    let m = $('<div class="wrapper" />').attr('tabIndex', '0');
    pkg.root.panel.bottom('binary-view', m, $('<i class="fa fa-file-text"> Binary</i>'));

    this.view = riot.mount(m[0], 'binary-view')[0];
    let ulhex = $(this.view.root).find('.hex');
    let ulascii = $(this.view.root).find('.ascii');

    Session.on('created', function(session) {
      ulhex.empty();
      ulascii.empty();
    });

    PubSub.sub('packet-view:range', function(array) {
      ulhex.find('i').removeClass('selected');
      ulascii.find('i').removeClass('selected');
      if (array.length > 0) {
        let range = [0, ulascii.find('i').length];
        for (let r of array) {
          if (r !== '') {
            let n = r.split(':');
            n[0] = (n[0] === '') ? 0 : parseInt(n[0]);
            n[1] = (n[1] === '') ? range[1] : parseInt(n[1]);
            range[0] = Math.min(range[0] + n[0], range[1]);
            range[1] = Math.min(range[0] + (n[1] - n[0]), range[1]);
          }
        }
        ulhex.find('i').slice(range[0], range[1]).addClass('selected');
        ulascii.find('i').slice(range[0], range[1]).addClass('selected');
      }
    });

    PubSub.sub('packet-list-view:select', (pkt) => {
      this.view.set(pkt);
      this.view.update();
    });
  }

  async deactivate() {
    let pkg = await Package.load('main-view');
    pkg.root.panel.bottom('binary-view');
    this.view.unmount();
    this.comp.destroy();
  }
}
