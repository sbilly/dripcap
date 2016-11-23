import config from 'dripcap-core/config';
import Profile from 'dripcap-core/profile';

let dripcap = {};
dripcap.Profile = new Profile(config.profilePath + '/default');

const load = require('module')._load;
require('module')._load = (request, parent, isMain) => {
  if (request === 'dripcap') {
    return dripcap;
  }
  return load(request, parent, isMain);
};
