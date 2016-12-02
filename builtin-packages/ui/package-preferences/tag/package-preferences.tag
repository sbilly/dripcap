<package-preferences-item>
  <li class="packages border">
    <p class="head">{ opts.pkg.name }
      <i class="text-label">{ opts.pkg.description }</i>
    </p>
    <ul class="items">
      <li>
        <label>
          <input type="checkbox" name="enabled" onclick={ parent.setEnabled } checked={ opts.pkg.config.get('enabled') }>
          Enabled
        </label>
      </li>
      <li>
        <div class="preferences"></div>
      </li>
      <li if={ opts.pkg.userPackage }>
        <input type="button" value="Uninstall" onclick={ parent.uninstallPackage }>
      </li>
    </ul>
  </li>
</package-preferences-item>

<package-preferences>
  <ul>
    <virtual data-is="package-preferences-item" each={ pkg in packageList } pkg={ pkg }></virtual>
  </ul>

  <script>
    const { Package } = require('dripcap');
    const $ = require('jquery');

    this.on('mount', () => {
      Package.sub('core:package-list-updated', list => {
        this.packageList = Object.keys(list).map(v => list[v]);
        this.update();
      });
    });

    setEnabled(e) {
      let { pkg } = e.item;
      let enabled = $(e.currentTarget).is(':checked');
      pkg.config.set('enabled', enabled);
      if (enabled) {
        pkg.activate();
      } else {
        pkg.deactivate();
      }
    }

    uninstallPackage(e) {
      let { pkg } = e.item;
      if (pkg.config.get('enabled')) {
        pkg.deactivate();
      }
      Package.uninstall(pkg.name).then(() => {
        $(e.target).parents('li.packages').fadeOut(400, () => {
          this.packageList.splice(this.packageList.indexOf(pkg), 1);
          this.update();
        });
      });
    }
  </script>

  <style type="text/less">
    :scope {
      li.packages {
        border: 1px solid var(--color-selection-background);
        margin: 20px 10px;
        padding: 15px;
        border-radius: 5px;
        p.head {
          margin: 0;
          i {
            float: right;
            width: 50%;
            text-align: right;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
          }
        }
      }
      ul.items {
        padding: 10px 0 0;
        li {
          padding: 5px 0;
          display: inline;
          input {
            max-width: 120px;
            margin: 0 10px;
          }
        }
        .preferences {
          margin: 20px 10px 10px;
        }
      }
      ul {
        list-style: none;
        padding: 0;
      }
    }
  </style>
</package-preferences>
