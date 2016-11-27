import $ from 'jquery';
import { Package, Menu, PubSub, Config, Logger } from 'dripcap-core';
import { remote } from 'electron';
let { MenuItem, app } = remote;

export default class LogView {
  constructor(pkg) {
    this.config = pkg.config;
  }

  async activate() {

  }

  async deactivate() {

  }
}
