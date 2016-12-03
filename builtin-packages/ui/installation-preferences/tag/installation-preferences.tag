<installation-preferences-item>
  <li class="packages border">
    <p class="head">{ opts.pkg.name } ({ opts.pkg.version })<i class="text-label">{ opts.pkg.description }</i>
    </p>
    <ul class="items">
      <li>
        <input type="button" disabled={ parent.installing } show={ opts.pkg.status === 'none' }      value="Install v{opts.pkg.version}" onclick={ parent.installPackage }>
        <input type="button" disabled={ parent.installing } show={ opts.pkg.status === 'old' }       value="Update to v{opts.pkg.version}" onclick={ parent.installPackage }>
        <input type="button" show={ opts.pkg.status === 'installed' } value="Up to date" disabled>
        <input type="button" disabled={ parent.installing } show={ opts.pkg.userPackage && opts.pkg.status !== 'none' } value="Uninstall" onclick={ parent.uninstallPackage }>
        </li>
      </li>
    </ul>
  </li>
</installation-preferences-item>

<installation-preferences>
  <ul>
    <li>
      <label>Package Registry:
      </label>
      { registry }
    </li>
    <li show={ installing }>
      <i class="fa fa-cog fa-spin"></i>
      Installing...
    </li>
    <li>
      { message }
    </li>
  </ul>

  <ul>
    <installation-preferences-item each={ pkg in packages } pkg={ pkg }></installation-preferences-item>
  </ul>

  <style type="text/less">
    :scope {
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
    const request = require('request');
    const semver = require('semver');
    const url = require('url');
    const { Package, PubSub, Profile } = require('dripcap');

    this.installing = false;
    this.message = '';
    this.remotePackages = [];
    this.packages = [];

    this.on('mount', () => {
      this.reload();
      this.registry = Profile.getConfig('package-registry');
      Package.resolveRegistry(this.registry).then((host) => {
        request(url.resolve(host, '/list'), (err, res, body) => {
          if (err != null) {
            this.message = "Error: failed to fetch the package lists!";
          } else {
            this.message = '';
            this.remotePackages = JSON.parse(body);
          }
          this.reload();
        });
      });
      PubSub.sub(this, 'core:package-list-updated', this.reload);
    });

    this.on('unmount', () => {
      PubSub.removeHolder(this);
    });

    reload() {
      this.packages = [];
      for (let pkg of this.remotePackages) {
        pkg.status = 'none';
        let loaded = Package.list[pkg.name];
        if (loaded != null) {
          pkg.userPackage = loaded.userPackage;
          if (semver.gt(pkg.version, loaded.version)) {
            pkg.status = 'old';
          } else {
            pkg.status = 'installed';
          }
        }
        this.packages.push(pkg);
      }
      this.update();
    };

    installPackage(e) {
      let {name} = e.item.pkg;
      this.installing = true;
      this.message = '';
      Package.install(name).then(() => {
        this.message = `${name} has been successfully installed!`;
        this.installing = false;
        this.update();
      }).catch(e => {
        this.message = e.toString();
        this.installing = false;
        this.update();
      });
      this.update();
    }

    uninstallPackage(e) {
      let {name} = e.item.pkg;
      let pkg = Package.list[name];
      if (pkg.config.get('enabled')) {
        pkg.deactivate();
      }
      Package.uninstall(pkg.name);
    }
  </script>

  <style type="text/less">
    :scope {
      padding: 10px 20px;

      li.packages {
        border: 1px solid var(--color-selection-background);
        margin: 20px 0;
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
      input[type=button][disabled] {
        opacity: 0.5;
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
</installation-preferences>
