export default class PubSub {
  constructor() {
    this._channels = {}
    this._holders = new WeakMap();
  }

  _getChannel(name) {
    if (this._channels[name] == null) {
      this._channels[name] = {
        queue: [],
        handlers: []
      };
    }
    return this._channels[name];
  }

  sub(holder, name, cb) {
    if (typeof holder === 'object') {
      if (!this._holders.has(holder)) {
        this._holders.set(holder, []);
      }
      let handlers = this._holders.get(holder);
      handlers.push({name, cb});
    } else {
      cb = name;
      name = holder;
    }
    const ch = this._getChannel(name);
    ch.handlers.push(cb);
    for (let data of ch.queue) {
      cb(data);
    }
  }

  pub(name, data, queue = 1) {
    const ch = this._getChannel(name);
    for (let cb of ch.handlers) {
      cb(data);
    }
    ch.queue.push(data);
    if (queue > 0 && ch.queue.length > queue) {
      ch.queue.splice(0, ch.queue.length - queue);
    }
  }

  on(holder, name, cb) {
    this.sub(holder, name, cb);
  }

  emit(name, data, queue = 0) {
    this.pub(name, data, queue);
  }

  get(name, index = 0) {
    const ch = this._getChannel(name);
    return ch.queue[ch.queue.length - index - 1];
  }

  removeListener(name, cb) {
    const ch = this._getChannel(name);
    let index = ch.handlers.indexOf(cb);
    if (index >= 0) ch.handlers.splice(index, 1);
  }

  removeHolder(holder) {
    if (this._holders.has(holder)) {
      let handlers = this._holders.get(holder, []);
      for (let h of handlers) {
        this.removeListener(h.name, h.cb);
      }
      this._holders.delete(holder);
    }
  }
}
