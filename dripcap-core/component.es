import $ from 'jquery';
import riot from 'riot';
import less from 'less';
import glob from 'glob';
import { rollup } from 'rollup';
import riotup from 'rollup-plugin-riot';

const tagPattern = /riot\.tag\('([a-z-]+)'/ig;

export default class Component {
  static async create() {
    let comp = new Component();

    comp._less = '';
    comp._names = [];

    const tags = arguments;
    for (let pattern of tags) {
      for (let tag of glob.sync(pattern)) {
        if (tag.endsWith('.tag')) {
          let bundle = await rollup({
            entry: tag,
            external: ['dripcap'],
            acorn: {
              ecmaVersion: 8
            },
            plugins: [
              riotup()
            ],
            onwarn: (e) => {}
          });
          const result = bundle.generate({
            format: 'cjs'
          });
          let code = result.code;
          let match;
          while (match = tagPattern.exec(code)) {
            comp._names.push(match[1]);
          }
          new Function(code)();
        } else if (tag.endsWith('.less')) {
          comp._less += `\n@import "${tag}";\n`;
        }
      }
    }

    if (comp._less.length > 0) {
      less.render(comp._less, (e, output) => {
        if (e != null) {
          throw e;
        } else {
          comp._css = $('<style>').text(output.css).appendTo($('head'));
        }
      });
    }

    return comp;
  }

  destroy() {
    for (let name of this._names) {
      riot.tag(name, '');
    }
    if (this._css != null)
      this._css.remove();
  }
}
