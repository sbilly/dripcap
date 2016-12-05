import { Layout, Preferences } from 'dripcap';

export default class GeneralPreferences {
  async activate() {
    Layout.require(__dirname + '/../tag/general-preferences.tag');
    Preferences.registerTab({
      id: 'general-preferences',
      name: 'General',
      center: {
        tag: 'general-preferences'
      }
    });
  }

  async deactivate() {
    Preferences.unregisterTab('general-preferences');
    Layout.unregister('general-preferences');
  }
}
