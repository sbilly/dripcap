<drip-modal-view>
  <div class="mask"></div>
  <div class="dialog">
    <drip-grid-container if={ this.items.length > 0 } item={ items[items.length - 1] }></drip-grid-container>
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
      background-color: var(--background3);
      opacity: 0.6;
      grid-column: 1 / 4;
      grid-row: 1 / 4;
      z-index: 1;
    }

    :scope > div.dialog {
      display: grid;
      grid-area: center;
      background-color: var(--background1);
      border-radius: 5px;
      border: 1px solid var(--color1);
      z-index: 2;
    }
  </style>

  <script>
    const $ = require('jquery');
    const {Layout} = require('dripcap');
    this.items = [];

    append(item) {
      this.items.push(item);
      this.update();
    }

    remove(id) {
      let index = this.items.findIndex((ele) => ele.id === id);
      if (index >= 0) {
        this.items.splice(index, 1);
        this.update();
      }
    }

    this.on('update', () => {
      $(this.root).toggle(this.items.length > 0);
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
