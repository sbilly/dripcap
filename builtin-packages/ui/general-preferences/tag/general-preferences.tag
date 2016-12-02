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

  <style>
    :scope {
      padding: 10px 20px;
    }

    :scope label {
      margin: 5px 0;
      display: block;
    }

    :scope > ul {
      list-style: none;
      padding: 0;
    }

    :scope > ul > li {
      padding: 6px 0;
    }
  </style>

  <script>
    const $ = require('jquery');
    const { Theme, Profile } = require('dripcap');

    this.on('mount', () => {
      this.currentSnaplen = Profile.getConfig('snaplen');

      Theme.sub('registry-updated', () => {
        this.setThemeList(Theme.registry);
        this.update();
      });

      Profile.watchConfig('theme', id => {
        this.currentTheme = id;
        this.update();
      });

      Profile.watchConfig('snaplen', len => {
        this.currentSnaplen = len;
        this.update();
      });
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
