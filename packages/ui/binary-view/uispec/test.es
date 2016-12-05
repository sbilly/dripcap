import assert from 'assert';

describe('binary view', function() {
  it('shows hex', async function() {
    await this.app.webContents.executeJavaScript('require("dripcap").PubSub.emit("core:new-live-session")');
    let option = '[data-is=session-dialog] select[ref=interface] option';
    await this.app.client.waitForExist(option, 10000);
    await this.app.webContents.executeJavaScript('require("jquery")("[data-is=session-dialog] input[type=button]").click();');
    let item = '[data-is=packet-list-view] div.packet.list-item';
    await this.app.client.waitForExist(item, 10000);
    await this.app.webContents.executeJavaScript(`require("jquery")("${item}").click();`);
    let hex = '[data-is=binary-view] i.list-item';
    await this.app.client.waitForExist(hex, 10000);
  });
});
