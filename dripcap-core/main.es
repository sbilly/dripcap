import { app, BrowserWindow } from 'electron';

app.commandLine.appendSwitch('js-flags', '--harmony-async-await --no-memory-reducer');

app.on('quit', () => {

});

app.on('window-all-closed', () => app.quit());

app.on('ready', () => {
  let options = {
    width: 1200,
    height: 800,
    show: false,
    titleBarStyle: 'hidden-inset'
  };

  let mainWindow = new BrowserWindow(options);
  mainWindow.loadURL(`file://${__dirname}/layout.htm`);
  mainWindow.webContents.on('did-finish-load', () => {
    mainWindow.show();
  });
});
