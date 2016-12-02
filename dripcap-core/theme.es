import fs from 'fs';
import { remote } from 'electron';
import $ from 'jquery';

export default class ThemeInterface {
  constructor(pubsub, id) {
    this.pubsub = pubsub;
    this.registry = {};

    this._defaultScheme = {
      name: 'Default',
      css: [`${__dirname}/default-theme.css`]
    };

    this.registerScheme('default', this._defaultScheme);
    this.setId(id);
  }

  registerScheme(id, scheme) {
    this.registry[id] = scheme;
    this.pubsub.pub('core:theme-registry-updated');
    if (this._id === id) {
      this.scheme = this.registry[id];
      this._update();
    }
  }

  unregisterScheme(id) {
    if (delete this.registry[id]) {
      this.pubsub.pub('core:theme-registry-updated');
      if (id === this._id) {
        this.setId('default');
      }
    }
  }

  _update() {
    $('style.theme-syle').remove();
    let styles = [];
    for (let css of this.scheme.css) {
      let data = fs.readFileSync(css, 'utf8');
      styles.push($('<style>').addClass('theme-syle').text(data));
    }
    $('head').append(styles);

    let computed = getComputedStyle(document.documentElement);
    let vibrancy = JSON.parse(computed.getPropertyValue('--vibrancy'));
    remote.getCurrentWindow().setVibrancy(vibrancy);
  }

  get id() {
    return this._id;
  }

  setId(id) {
    if (id != this._id) {
      this._id = id;
      if (this.registry[id] == null) {
        id = 'default';
      }
      if (this.scheme != this.registry[id]) {
        this.scheme = this.registry[id];
        this._update();
      }
    }
  }
}
