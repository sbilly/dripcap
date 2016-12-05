import assert from 'assert';

describe('packet view', function() {
  it('shows layers', async function() {
    await this.app.webContents.executeJavaScript('require("dripcap").PubSub.emit("core:new-live-session")');
    let option = '[data-is=session-dialog] select[ref=interface] option';
    await this.app.client.waitForExist(option, 10000);
    await this.app.webContents.executeJavaScript('require("jquery")("[data-is=session-dialog] input[type=button]").click();');
    let item = '[data-is=packet-list-view] div.packet.list-item';
    await this.app.client.waitForExist(item, 10000);
    await this.app.webContents.executeJavaScript(`require("jquery")("${item}").click();`);
    let layer = '[data-is=packet-view] p.layer-name';
    await this.app.client.waitForExist(layer, 10000);
  });
});
