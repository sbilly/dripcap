<drip-grid-container>
  <div>
     <div data-is={ opts.item.center }></div>
  </div>
  <script>
    const {Layout} = require('dripcap');

    this.on('mount', () => {
      if (opts.item.id) {
        Layout.registerContainer(opts.item.id, this);
      }
    });
    this.on('unmount', () => {
      if (opts.item.id) {
        Layout.unregisterContainer(opts.item.id);
      }
    });
  </script>
</drip-grid-container>
