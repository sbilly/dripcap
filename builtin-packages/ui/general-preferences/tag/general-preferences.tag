<general-preferences>
  <ul>
    <li>
      <label for="theme">Theme</label>
      <select ref="theme" onchange={ updateTheme }>
        <option each={ theme, id in themeList } value={ id } selected={ id==currentTheme }>{ theme.name }</option>
      </select>
    </li>
    <li>
      <label for="snaplen">Snapshot Length (bytes)</label>
      <input type="number" ref="snaplen" placeholder="1600" onchange={ updateSnaplen } value={ currentSnaplen }>
    </li>
  </ul>

  <style type="text/less">
    :scope {
      padding: 10px 20px;

      label {
        margin: 5px 0;
        display: block;
      }

      ul {
        list-style: none;
        padding: 0;
      }

      li {
        padding: 6px 0;
      }
    }
  </style>

  <script>
    const $ = require('jquery');
    const { PubSub, Theme, Profile } = require('dripcap');

    this.on('mount', () => {
      this.currentSnaplen = Profile.getConfig('snaplen');

      PubSub.sub('core:theme-registry-updated', () => {
        this.setThemeList(Theme.registry);
        this.update();
      });

      this._setCurrentTheme = (id) => {
        this.currentTheme = id;
        this.update();
      };
      
      this._setCurrentSnaplen = (len) => {
        this.currentSnaplen = len;
        this.update();
      };

      Profile.watchConfig('theme', this._setCurrentTheme);
      Profile.watchConfig('snaplen', this._setCurrentSnaplen);
    });


    this.on('unmount', () => {
      Profile.unwatchConfig('theme', this._setCurrentTheme);
      Profile.unwatchConfig('snaplen', this._setCurrentSnaplen);
    });

    setThemeList(list) {
      this.currentTheme = Theme.id;
      this.themeList = list;
    }

    updateTheme() {
      let id = $(this.refs.theme).val();
      Theme.setId(id);
      Profile.setConfig('theme', id);
    }

    updateSnaplen() {
      let len = parseInt($(this.refs.snaplen).val());
      Profile.setConfig('snaplen', len);
    }
  </script>

</general-preferences>
