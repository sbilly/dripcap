import { app, BrowserWindow } from 'electron';
import minimist from 'minimist';

app.commandLine.appendSwitch('js-flags', '--harmony-async-await --no-memory-reducer');
app.commandLine.appendSwitch('--enable-experimental-web-platform-features');

app.on('quit', () => {

});

app.on('window-all-closed', () => app.quit());

app.on('ready', () => {
  let options = {
    width: 1200,
    height: 600,
    show: false,
    vibrancy: 'light',
    titleBarStyle: 'hidden-inset'
  };

  let argv = JSON.stringify(minimist(process.argv.slice(2)));

  let mainWindow = new BrowserWindow(options);
  mainWindow.loadURL(`file://${__dirname}/layout.htm`);
  mainWindow.webContents.on('did-finish-load', () => {
    mainWindow.webContents.executeJavaScript(`require("./dripcap")(${argv}, "default")`, false).then(() => {
      mainWindow.show();
    });
  });
});
