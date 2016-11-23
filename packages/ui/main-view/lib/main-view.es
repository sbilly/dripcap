import $ from 'jquery';
import Component from 'dripcap-core/component';
import Panel from 'dripcap-core/panel';

export default class MainView {
  async activate() {
    this._comp = await Component.create(`${__dirname}/../less/*.less`);
    this.panel = new Panel();
    this._elem = $('<div id="main-view">').append(this.panel.root);
    this._elem.appendTo($('body'));
  }

  async deactivate() {
    this._elem.remove();
    this._comp.destroy();
  }
}
