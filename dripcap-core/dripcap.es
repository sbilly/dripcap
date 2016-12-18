import path from 'path';
import $ from 'jquery';
import { webFrame } from 'electron';
import Env from './env';
import Profile from './profile';
import Theme from './theme';
import Menu from './menu';
import Layout from './layout';
import PackageHub from './package-hub';
import KeyBind from './keybind';
import PubSub from './pubsub';
import Session from './session';
import Logger from './logger';
import init from './init';

export default function(profileName = 'default') {
  Object.defineProperty(document, 'createElementNS', {
    value: document.createElementNS
  });

  let profile = new Profile(path.join(Env.profilePath, profileName));
  let pubsub = new PubSub();
  let layout = new Layout(pubsub);
  let dripcap = {
    Env: Env,
    Profile: profile,
    Theme: new Theme(pubsub, profile.getConfig('theme')),
    Menu: new Menu(),
    Layout: layout,
    Package: new PackageHub(pubsub, profile),
    KeyBind: new KeyBind(profile, pubsub),
    PubSub: pubsub,
    Logger: new Logger(pubsub),
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

  webFrame.setZoomLevelLimits(1.0, 1.0);

  module.globalPaths.push(path.dirname(__dirname));
  return init(dripcap);
}
