import assert from 'assert';

describe('log view', function() {
  it('shows logs', async function() {
    this.app.webContents.executeJavaScript('require("dripcap").PubSub.emit("log-view:toggle");');
    await this.app.client.waitForExist('[data-is=log-view] li');
  });
});
