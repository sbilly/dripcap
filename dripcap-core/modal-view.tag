<drip-modal-view>
  <div class="mask" onclick={ close }></div>
  <div class="dialog">
    <drip-tab-view if={ items } items={ items }></drip-tab-view>
  </div>
  <style>
    :scope {
      display: grid;
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
      -webkit-app-region: none;
    }

    :scope > div.dialog {
      display: grid;
      grid-area: center;
      background-color: var(--color-default-background);
      border-radius: 5px;
      border: 1px solid var(--color-variables);
      z-index: 2;
    }

    :scope > div.dialog > drip-grid-container > div.center {
      padding: 20px;
    }
  </style>

  <script>
    const $ = require('jquery');
    const {Layout} = require('dripcap');
    this.items = null;

    set(items, opts = {}) {
      this.items = items;
      let width = opts.width || '480px';
      let height = opts.height || '320px';
      $(this.root)
        .css('grid-template-columns', `1fr ${width} 1fr`)
        .css('grid-template-rows', `1fr ${height} 1fr`);
      this.update();
    }

    close() {
      this.set();
    }

    this.on('update', () => {
      $(this.root).toggle(!!this.items);
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
