import path from 'path';
import config from 'dripcap-core/config';
import Profile from 'dripcap-core/profile';
import Theme from 'dripcap-core/theme';

export default function(profileName = 'default') {
  let profile = new Profile(path.join(config.profilePath, profileName))
  let dripcap = {
    Profile: profile,
    Theme: new Theme(profile.getConfig('theme') + '_')
  };

  const load = require('module')._load;
  require('module')._load = (request, parent, isMain) => {
    if (request === 'dripcap') {
      return dripcap;
    }
    return load(request, parent, isMain);
  };
}
