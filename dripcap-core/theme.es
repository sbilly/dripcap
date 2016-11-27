import PubSub from './pubsub';
import fs from 'fs';
import { remote } from 'electron';
import $ from 'jquery';

export default class ThemeInterface extends PubSub {
  constructor(id) {
    super();
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
    this.pub('registry-updated', null, 1);
    if (this._id === id) {
      this.scheme = this.registry[id];
      this.pub('update', this.scheme, 1);
      this._update();
    }
  }

  unregisterScheme(id) {
    if (delete this.registry[id]) {
      this.pub('registry-updated', null, 1);
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

    //let computed = getComputedStyle(document.documentElement);
    //let vibrancy = JSON.parse(computed.getPropertyValue('--vibrancy'));
    //remote.getCurrentWindow().setVibrancy(vibrancy);
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
        this.pub('update', this.scheme, 1);
        this._update();
      }
    }
  }
}
