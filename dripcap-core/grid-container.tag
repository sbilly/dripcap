<drip-container>
  <virtual data-is={ opts.item.tag }></virtual>
  <script>
    const {Layout} = require('dripcap');
    this.on('mount', () => {
      if (opts.item.id) {
        Layout.registerContainer(opts.item.id, this);
      }
    });
  </script>
</drip-container>

<drip-grid-container>
  <div class="center" tabindex="0" if={ opts.item.center }>
     <virtual data-is="drip-container" item={ opts.item.center }></virtual>
  </div>
  <div class="top" if={ opts.item.top }>
     <virtual data-is="drip-container" item={ opts.item.top }></virtual>
  </div>
  <div class="bottom" if={ opts.item.bottom }>
     <virtual data-is="drip-container" item={ opts.item.bottom }></virtual>
  </div>
  <div class="left" if={ opts.item.left }>
     <virtual data-is="drip-container" item={ opts.item.left }></virtual>
  </div>
  <div class="right" if={ opts.item.right }>
     <virtual data-is="drip-container" item={ opts.item.right }></virtual>
  </div>

  <style type="text/less">
    :scope {
      display: grid;
      grid-template-columns: 32px 1fr 32px;
      grid-template-rows: 32px 1fr 32px;
      grid-template-areas: "top top top"
                           "left center right"
                           "bottom bottom bottom";
      -webkit-app-region: no-drag;

      > div {
        display: grid;
      }
      > div.center {
        grid-area: center;
        overflow: auto;
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        outline-offset: -3px;
      }
      > div.top {
        grid-area: top;
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
      }
      > div.bottom {
        grid-area: bottom;
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
      }
      > div.left {
        grid-area: left;
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
      }
      > div.right {
        grid-area: right;
      }
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

      if (opts.item.top) {
        top = opts.item.top.size || '32px';
      }
      if (opts.item.bottom) {
        bottom = opts.item.bottom.size || '32px';
      }
      if (opts.item.left) {
        left = opts.item.left.size || '32px';
      }
      if (opts.item.right) {
        right = opts.item.right.size || '32px';
      }

      $(this.root)
        .css('grid-template-columns', `${left} 1fr ${right}`)
        .css('grid-template-rows', `${top} 1fr ${bottom}`);
    }

    setCenter(item) {
      if (opts.item.center != item) {
        opts.item.center = item;
        this.updateLayout();
        this.update();
      }
    }
    setTop(item) {
      if (opts.item.top != item) {
        opts.item.top = item;
        this.updateLayout();
        this.update();
      }
    }
    setBottom(item) {
      if (opts.item.bottom != item) {
        opts.item.bottom = item;
        this.updateLayout();
        this.update();
      }
    }
    setLeft(item) {
      if (opts.item.left != item) {
        opts.item.left = item;
        this.updateLayout();
        this.update();
      }
    }
    setRight(item) {
      if (opts.item.right != item) {
        opts.item.right = item;
        this.updateLayout();
        this.update();
      }
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
