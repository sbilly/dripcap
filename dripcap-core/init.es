import { remote, shell } from 'electron';

export default function init(dripcap) {
  let { Theme, PubSub, Package } = dripcap;

  Theme.registerLess(__dirname + '/layout.less', (css) => {
    console.log(css)
  });

  PubSub.on('core:new-window', () => remote.getGlobal('dripcap-core').newWindow());
  PubSub.on('core:close-window', () => remote.getCurrentWindow().close());
  PubSub.on('core:reload-window', () => remote.getCurrentWindow().reload());
  PubSub.on('core:toggle-devtools', () => remote.getCurrentWindow().toggleDevTools());
  PubSub.on('core:window-zoom', () => remote.getCurrentWindow().maximize());
  PubSub.on('core:open-user-directroy', () => shell.showItemInFolder(config.profilePath));
  PubSub.on('core:open-website', () => shell.openExternal('https://dripcap.org'));
  PubSub.on('core:open-wiki', () => shell.openExternal('https://github.com/dripcap/dripcap/wiki'));
  PubSub.on('core:show-license', () => shell.openExternal('https://github.com/dripcap/dripcap/blob/master/LICENSE'));
  PubSub.on('core:quit', () => remote.app.quit());

  Package.updatePackageList();
}
