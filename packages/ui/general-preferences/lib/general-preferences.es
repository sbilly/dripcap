import { Layout } from 'dripcap';

export default class GeneralPreferences {
  async activate() {
    Layout.require(__dirname + '/../tag/general-preferences.tag');
    Layout.registerPreferenceTab({
      id: 'general-preferences',
      name: 'General',
      center: {
        tag: 'general-preferences'
      }
    });
  }

  async deactivate() {
    Layout.unregisterPreferenceTab('general-preferences');
    Layout.unregister('general-preferences');
  }
}
