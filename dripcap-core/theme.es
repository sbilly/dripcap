import PubSub from './pubsub';
import css from 'css';
import less from 'less';
import fs from 'fs';

export default class ThemeInterface extends PubSub {
  constructor(id) {
    super();
    this.registry = {};
    this._less = {};

    this._defaultScheme = {
      name: 'Default',
      less: [`${__dirname}/default-theme.less`]
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
    }
  }

  unregisterScheme(id) {
    delete this.registry[id];
    this.pub('registry-updated', null, 1);
    if (id === this.id) {
      this.id = 'default';
    }
  }

  registerLess(file, cb) {
    if (this._less[file] == null) {
      this._less[file] = cb;
      this._render(file);
    }
  }

  unregisterLess(file) {
    delete this._less[file];
  }

  _render(file) {
    fs.readFile(file, 'utf8', (err, input) => {
      for (let less of this.scheme.less) {
        input = `@import "${less}";\n` + input;
      }
      less.render(input, {})
      .then((output) => {
        if (this._less[file] != null) {
          this._less[file](output.css);
        }
      });
    });
  }

  _update() {
    let virtual = `
      @vibrancy: 'dark';
    `;
    for (let less of this.scheme.less) {
      virtual += `@import "${less}";\n`;
    }
    virtual += `
      :void {
        vibrancy: @vibrancy;
      }
    `;
    less.render(virtual, {})
    .then((output) => {
      let result = css.parse(output.css);
      let decl = result.stylesheet.rules[0].declarations;
      let prop = {};
      for (let m of decl) {
        prop[m.property] = m.value;
      }
    });
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
        for (let file in this._less) {
          this._render(file);
        }
        this._update();
      }
    }
  }
}
