import path from 'path';
import $ from 'jquery';
import config from './config';
import Profile from './profile';
import Theme from './theme';
import Menu from './menu';
import PackageHub from './package-hub';
import KeyBind from './keybind';
import { EventEmitter } from 'events';
import { remote } from 'electron';

export default function(profileName = 'default') {
  let profile = new Profile(path.join(config.profilePath, profileName));
  let action = new EventEmitter();
  let dripcap = {
    Config: config,
    Profile: profile,
    Theme: new Theme(profile.getConfig('theme') + '_'),
    Menu: new Menu(),
    Package: new PackageHub(profile),
    KeyBind: new KeyBind(profile, action),
    Action: action
  };

  const load = require('module')._load;
  require('module')._load = (request, parent, isMain) => {
    if (request === 'dripcap') {
      return dripcap;
    }
    return load(request, parent, isMain);
  };

  init(dripcap);
}

function init(dripcap) {
  let { Theme, Action, Package } = dripcap;
  Theme.registerLess(__dirname + '/layout.less', (css) => {
    console.log(css)
  });

  Action.on('core:toggle-devtools', () => remote.getCurrentWindow().toggleDevTools());
  Package.updatePackageList();
}
