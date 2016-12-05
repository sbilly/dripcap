export default class Preferences {
  constructor(layout, pubsub) {
    this.items = [];
    pubsub.on('core:show-preferences', () => {
      layout.container('drip-modal').set(this.items, {width: '600px', height: '420px'});
    });
  }

  registerTab(item) {
    this.items.push(item);
  }

  unregisterTab(id) {
    let index = this.items.findIndex((ele) => ele.id === id);
    if (index >= 0) this.items.splice(index, 1);
  }
};
