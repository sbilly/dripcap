import { Package, Layout } from 'dripcap';

export default class PackagePreferences {
  async activate() {
    Layout.require(__dirname + '/../tag/package-preferences.tag');
    Layout.registerPreferenceTab({
      id: 'package-preferences',
      name: 'Packages',
      center: {
        tag: 'package-preferences'
      }
    });
  }

  async deactivate() {
    Layout.unregisterPreferenceTab('package-preferences');
    Layout.unregister('package-preferences');
  }
}
