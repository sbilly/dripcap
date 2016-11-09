import fs from 'fs';
import path from 'path';
import _ from 'underscore';
import { rollup } from 'rollup';
import config from 'dripcap/config';
import {
  EventEmitter
} from 'events';

export default class Package extends EventEmitter {
  constructor(jsonPath, profile) {
    super();
    this._activated = false;

    this.path = path.dirname(jsonPath);
    this.userPackage = path.normalize(this.path).startsWith(path.normalize(config.userPackagePath));

    let info = JSON.parse(fs.readFileSync(jsonPath));

    if (info.name != null) {
      this.name = info.name;
    } else {
      throw new Error('package name required');
    }

    if ((info._dripcap != null) && (info._dripcap.name != null)) {
      this.name = info._dripcap.name;
    }

    if (info.main != null) {
      this.main = info.main;
    } else {
      throw new Error('package main required');
    }

    this.description = info.description != null ? info.description : '';
    this.version = info.version != null ? info.version : '0.0.1';
    this.config = profile.getPackageConfig(this.name);
    this._reset();
  }

  _reset() {
    return this._promise =
      new Promise(resolve => {
        return this._resolve = resolve;
      })
      .then(() => {
        return new Promise((resolve, reject) => {
          let req = path.resolve(this.path, this.main);
          rollup({
            entry: req,
            external: ['dripcap'],
            acorn: {
              ecmaVersion: 8
            },
            plugins: [{
              name: 'globalPaths',
              banner: `require('module').globalPaths.push('${this.path}/node_modules')`
            }],
            onwarn: (e) => {}
          }).then((bundle) => {
            const result = bundle.generate({
              format: 'cjs'
            });
            let module = {exports: {}};

            try {
              new Function('module', '__dirname', result.code)(module, path.dirname(req));
              let klass = module.exports;
              this.root = new klass(this);
              let res = this.root.activate();
              if (res instanceof Promise) {
                return res.then(() => resolve(this));
              } else {
                return resolve(this);
              }
            } catch (e) {
              reject(e);
              return;
            }
          });
        });
      });
  }

  load() {
    return this._promise;
  }

  activate() {
    if (this._activated) return;
    this._activated = true;
    if (!this.path.includes('/app.asar/')) {
      this._watcher = fs.watch(this.path, {recursive: true}, _.debounce(() => {
        this.emit('file-updated');
      }, 100));
    }
    return this._resolve();
  }

  renderPreferences() {
    if ((this.root != null) && (this.root.renderPreferences != null)) {
      return this.root.renderPreferences();
    } else {
      return null;
    }
  }

  async deactivate() {
    if (!this._activated) return;
    this._activated = false;
    await this.load();
    if (this._watcher) this._watcher.close();
    return new Promise((resolve, reject) => {
      if (this.root != null) {
        try {
          this.root.deactivate();
          this.root = null;
          this._reset();
          for (let key in require.cache) {
            if (key.startsWith(this.path)) {
              delete require.cache[key];
            }
          }
        } catch (e) {
          reject(e);
          return;
        }
      }
      return resolve(this);
    });
  }
}
