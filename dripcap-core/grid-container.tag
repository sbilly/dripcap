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
    :scope > div.top {
      grid-area: top;
    }
    :scope > div.bottom {
      grid-area: bottom;
    }
    :scope > div.left {
      grid-area: left;
    }
    :scope > div.right {
      grid-area: right;
    }
  </style>

  <script>
    const {Layout} = require('dripcap');
    const $ = require('jquery');

    updateLayout() {
      let top = '0';
      let bottom = '0';
      let left = '0';
      let right = '0';

      $(this.root)
        .css('grid-template-columns', `${left} 1fr ${right}`)
        .css('grid-template-rows', `${top} 1fr ${bottom}`);
    }

    this.on('update', () => {
      this.updateLayout();
    });
    this.on('mount', () => {
      if (opts.item.id) {
        Layout.registerContainer(opts.item.id, this);
      }
      this.updateLayout();
    });
    this.on('unmount', () => {
      if (opts.item.id) {
        Layout.unregisterContainer(opts.item.id);
      }
    });
  </script>
</drip-grid-container>
