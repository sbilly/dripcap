import { remote, shell } from 'electron';

export default function init(dripcap) {
  let { Theme, Action, Package } = dripcap;

  Theme.registerLess(__dirname + '/layout.less', (css) => {
    console.log(css)
  });

  Action.on('core:new-window', () => remote.getGlobal('dripcap-core').newWindow());
  Action.on('core:close-window', () => remote.getCurrentWindow().close());
  Action.on('core:reload-window', () => remote.getCurrentWindow().reload());
  Action.on('core:toggle-devtools', () => remote.getCurrentWindow().toggleDevTools());
  Action.on('core:window-zoom', () => remote.getCurrentWindow().maximize());
  Action.on('core:open-user-directroy', () => shell.showItemInFolder(config.profilePath));
  Action.on('core:open-website', () => shell.openExternal('https://dripcap.org'));
  Action.on('core:open-wiki', () => shell.openExternal('https://github.com/dripcap/dripcap/wiki'));
  Action.on('core:show-license', () => shell.openExternal('https://github.com/dripcap/dripcap/blob/master/LICENSE'));
  Action.on('core:quit', () => remote.app.quit());

  Package.updatePackageList();
}
