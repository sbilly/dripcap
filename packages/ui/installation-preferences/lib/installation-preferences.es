import { Package, Layout } from 'dripcap';

export default class PackagePreferences {
  async activate() {
    Layout.require(__dirname + '/../tag/installation-preferences.tag');
    Layout.registerPreferenceTab({
      id: 'installation-preferences',
      name: 'Install',
      center: {
        tag: 'installation-preferences'
      }
    });
  }

  async deactivate() {
    Layout.unregisterPreferenceTab('installation-preferences');
    Layout.unregister('installation-preferences');
  }
}
