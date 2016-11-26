import { app, BrowserWindow } from 'electron';

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
    vibrancy: 'dark',
    titleBarStyle: 'hidden-inset'
  };

  let mainWindow = new BrowserWindow(options);
  mainWindow.loadURL(`file://${__dirname}/layout.htm`);
  mainWindow.webContents.on('did-finish-load', () => {
    mainWindow.webContents.executeJavaScript('require("./dripcap")("default")', false).then(() => {
      mainWindow.show();
    });
  });
});
