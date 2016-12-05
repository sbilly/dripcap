import { Package, Layout, Preferences } from 'dripcap';

export default class PackagePreferences {
  async activate() {
    Layout.require(__dirname + '/../tag/package-preferences.tag');
    Preferences.registerTab({
      id: 'package-preferences',
      name: 'Packages',
      center: {
        tag: 'package-preferences'
      }
    });
  }

  async deactivate() {
    Preferences.unregisterTab('package-preferences');
    Layout.unregister('package-preferences');
  }
}
