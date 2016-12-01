import { Theme } from 'dripcap';

export default class Base16 {
  activate() {
    Theme.registerScheme('base16-oceanic-next-light', {
      name: "Oceanic Next Light",
      css: [`${__dirname}/../css/oceanic-next-light.css`]
    });
    Theme.registerScheme('base16-green-screen', {
      name: "Oceanic Next Light",
      css: [`${__dirname}/../css/green-screen.css`]
    });
  }

  deactivate() {
    Theme.unregisterScheme('base16-oceanic-next-light');
    Theme.unregisterScheme('base16-green-screen');
  }
}
