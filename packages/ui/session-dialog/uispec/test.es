import assert from 'assert';

describe('session dialog', function() {
  it('shows an interface list', async function() {
    await this.app.webContents.executeJavaScript('require("dripcap").PubSub.emit("core:new-live-session")');
    let option = '[data-is=session-dialog] select[ref=interface] option';
    await this.app.client.waitForExist(option, 10000);
    let val = await this.app.client.getAttribute(option, 'value')
    assert.deepEqual(['eth0', 'lo'], val);
  });
  it('shows a start button', async function() {
    await this.app.webContents.executeJavaScript('require("dripcap").PubSub.emit("core:new-live-session")');
    let val = await this.app.client.getAttribute('[data-is=session-dialog] input[type=button]', 'value')
    assert.equal('Start', val);
  });
});
