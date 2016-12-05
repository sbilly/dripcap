import * as riot from 'riot';

export default class Layout {
  constructor() {
    this._container = {};
  }

  container(id) {
    return this._container[id];
  }

  registerContainer(id, view) {
    this._container[id] = view;
  }

  unregisterContainer(id) {
    delete this._container[id];
  }

  require(tag) {
    riot.require(tag);
    riot.util.styleManager.inject();
  }

  unregister(tagName) {
    riot.unregister(tagName);
  }
}
