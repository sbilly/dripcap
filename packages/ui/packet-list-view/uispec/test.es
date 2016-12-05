import assert from 'assert';

describe('packet list view', function() {
  it('shows packets', async function() {
    await this.app.webContents.executeJavaScript('require("dripcap").PubSub.emit("core:new-live-session")');
    let option = '[data-is=session-dialog] select[ref=interface] option';
    await this.app.client.waitForExist(option, 10000);
    await this.app.webContents.executeJavaScript('require("jquery")("[data-is=session-dialog] input[type=button]").click();');
    let selector = '[data-is=packet-list-view] div.packet.list-item';
    await this.app.client.waitForExist(selector, 10000);
  });
});
