import $ from 'jquery';
import riot from 'riot';
import Component from 'dripcap-core/component';
import {
  Package
} from 'dripcap-core';

export default class PacketFilterView {
  async activate() {
    this.comp = await Component.create(`${__dirname}/../tag/*.tag`);
    let pkg = await Package.load('main-view');
    let m = $('<div/>');
    this.view = riot.mount(m[0], 'packet-filter-view')[0];
    pkg.root.panel.leftSouthFixed(m);
  }

  async deactivate() {
    let pkg = await Package.load('main-view');
    pkg.root.panel.leftSouthFixed();
    this.view.unmount();
    this.comp.destroy();
  }
}
