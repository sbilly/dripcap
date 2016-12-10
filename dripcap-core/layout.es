import * as riot from 'riot';

export default class Layout {
  constructor(pubsub) {
    this._container = {};
    this._preferences = [];
    pubsub.on('core:show-preferences', () => {
      this.container('drip-modal').set(this._preferences, {width: '600px', height: '420px'});
    });
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

  registerPreferenceTab(item) {
    this._preferences.push(item);
  }

  unregisterPreferenceTab(id) {
    let index = this._preferences.findIndex((ele) => ele.id === id);
    if (index >= 0) this._preferences.splice(index, 1);
  }
}
