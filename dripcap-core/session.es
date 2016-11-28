import config from './config';
import { EventEmitter } from 'events';
import paperfilter from 'paperfilter';

export default class Session extends EventEmitter {
  constructor(pubsub) {
    super();
    this._pubsub = pubsub;
    this._dissectors = [];
    this._streamDissectors = [];
    this._filterHints = {};
  }

  async getInterfaceList() {
    return paperfilter.Session.devices;
  }

  registerDissector(script) {
    this._dissectors.push({
      script
    });
  }

  registerStreamDissector(script) {
    this._streamDissectors.push({
      script
    });
  }

  unregisterDissector(script) {
    let index = this._dissectors.find(e => e.path === script);
    if (index != null) {
      this._dissectors.splice(index, 1);
    }
  }

  unregisterStreamDissector(script) {
    let index = this._streamDissectors.find(e => e.path === script);
    if (index != null) {
      this._streamDissectors.splice(index, 1);
    }
  }

  registerFilterHints(name, hints) {
    this._filterHints[name] = hints;
    this._updateFilterHints();
  }

  unregisterFilterHints(name) {
    if (delete this._filterHints[name]) {
      this._updateFilterHints();
    }
  }

  _updateFilterHints() {
    let hints = [];
    for (let key in this._filterHints) {
      hints = hints.concat(this._filterHints[key]);
    }
    hints.sort((a, b) => {
      if (a.filter === b.filter) return 0;
      return (a.filter < b.filter) ? 1 : -1;
    });
    this._pubsub.pub('core:filter-hints', hints);
  }

  async create(iface = '', options = {}) {
    let option = {
      namespace: '::<Ethernet>',
      dissectors: this._dissectors,
      stream_dissectors: this._streamDissectors
    };

    let sess = await paperfilter.Session.create(option);
    sess.interface = iface;

    if (options.filter != null) {
      sess.setBPF(options.filter);
    }

    return sess;
  }
}
