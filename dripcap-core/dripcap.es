import path from 'path';
import $ from 'jquery';
import config from './config';
import Profile from './profile';
import Theme from './theme';
import Menu from './menu';
import PackageHub from './package-hub';
import KeyBind from './keybind';
import PubSub from './pubsub';
import Session from './session';
import init from './init';

export default function(profileName = 'default') {
  let profile = new Profile(path.join(config.profilePath, profileName));
  let pubsub = new PubSub();
  let dripcap = {
    Config: config,
    Profile: profile,
    Theme: new Theme(profile.getConfig('theme') + '_'),
    Menu: new Menu(),
    Package: new PackageHub(profile),
    KeyBind: new KeyBind(profile, pubsub),
    PubSub: pubsub,
    Session: new Session(pubsub)
  };

  let module = require('module');
  const load = module._load;
  module._load = (request, parent, isMain) => {
    if (request === 'dripcap') {
      return dripcap;
    }
    return load(request, parent, isMain);
  };

  module.globalPaths.push(path.dirname(__dirname));
  return init(dripcap);
}
