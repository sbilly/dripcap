import { Package, Layout, Preferences } from 'dripcap';

export default class PackagePreferences {
  async activate() {
    Layout.require(__dirname + '/../tag/installation-preferences.tag');
    Preferences.registerTab({
      id: 'installation-preferences',
      name: 'Install',
      center: {
        tag: 'installation-preferences'
      }
    });
  }

  async deactivate() {
    Preferences.unregisterTab('installation-preferences');
    Layout.unregister('installation-preferences');
  }
}
