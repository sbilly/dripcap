import PubSub from './pubsub';

export default class ThemeInterface extends PubSub {
  constructor(id) {
    super();
    this.registry = {};

    this._defaultScheme = {
      name: 'Default',
      less: [`${__dirname}/default-theme.less`]
    };

    this.register('default', this._defaultScheme);
    this.setId(id);
  }

  register(id, scheme) {
    this.registry[id] = scheme;
    this.pub('registry-updated', null, 1);
    if (this._id === id) {
      this.scheme = this.registry[id];
      this.pub('update', this.scheme, 1);
    }
  }

  unregister(id) {
    delete this.registry[id];
    this.pub('registry-updated', null, 1);
    if (id === this.id) {
      this.id = 'default';
    }
  }

  get id() {
    return this._id;
  }

  setId(id) {
    if (id != this._id) {
      this._id = id;
      if (this.registry[id] != null) {
        this.scheme = this.registry[id];
        this.pub('update', this.scheme, 1);
      } else {
        id = 'default';
      }
      if (this.scheme != this.registry[id]) {
        this.scheme = this.registry[id];
        this.pub('update', this.scheme, 1);
      }
    }
  }
}
