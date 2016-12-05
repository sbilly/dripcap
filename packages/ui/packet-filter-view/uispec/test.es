import assert from 'assert';

describe('packet filter view', function() {
  it('shows filter input', async function() {
    return this.app.client.waitForExist('[data-is=packet-filter-view] input[type=text]');
  });
});
