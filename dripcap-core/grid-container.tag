<drip-container>
  <div data-is={ opts.item.tag }></div>
</drip-container>

<drip-grid-container>
  <div class="center" if={ opts.item.center }>
     <virtual data-is="drip-container" item={ opts.item.center }></virtual>
  </div>

  <style>
    :scope {
      display: grid;
      grid-template-columns: 32px 1fr 32px;
      grid-template-rows: 32px 1fr 32px;
      grid-template-areas: "top top top"
                           "left center right"
                           "bottom bottom bottom";
    }

    :scope > div {
      display: grid;
    }

    :scope > div.center {
      grid-area: center;
    }
  </style>

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
