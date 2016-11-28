<drip-modal-view>
  <div class="mask"></div>
  <div class="dialog">
    <drip-grid-container if={ item } item={ item }></drip-grid-container>
  </div>
  <style>
    :scope {
      display: grid;
      grid-template-columns: 1fr 480px 1fr;
      grid-template-rows: 1fr 300px 1fr;
      grid-template-areas: ". . ."
                           ". center ."
                           ". . .";
    }

    :scope > div.mask {
      background-color: var(--color-selection-background);
      opacity: 0.6;
      grid-column: 1 / 4;
      grid-row: 1 / 4;
      z-index: 1;
    }

    :scope > div.dialog {
      display: grid;
      grid-area: center;
      background-color: var(--color-default-background);
      border-radius: 5px;
      border: 1px solid var(--color-variables);
      z-index: 2;
    }
  </style>

  <script>
    const $ = require('jquery');
    const {Layout} = require('dripcap');
    this.item = null;

    set(item) {
      this.item = item;
      this.update();
    }

    this.on('update', () => {
      $(this.root).toggle(!!this.item);
    });
    this.on('mount', () => {
      $(this.root).hide();
      if (opts.dataContainerId) {
        Layout.registerContainer(opts.dataContainerId, this);
      }
    });
    this.on('unmount', () => {
      if (opts.dataContainerId) {
        Layout.unregisterContainer(opts.dataContainerId);
      }
    });
  </script>
</drip-modal-view>
