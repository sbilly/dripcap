<drip-tab-view>
  <div class="tab-bar" show={ items.length > 1 }>
    <div tabindex="0" each={ item, i in items }  class={ tab: true, selected: i == this.activeIndex } onkeypress={ setIndexKey } onclick={ setIndex }> { item.name } </div>
  </div>
  <virtual each={ item, i in items }>
    <drip-grid-container item={ item } show={ i == this.activeIndex } class={ show-tab: items.length > 1 }></drip-grid-container>
  </virtual>
  <style>
    :scope > drip-grid-container.show-tab {
      top: 32px;
    }
    :scope > drip-grid-container {
      position: absolute;
      top: 0;
      bottom: 0;
      right: 0;
      left: 0;
    }
    :scope > div.tab-bar {
      position: absolute;
      top: 0;
      right: 0;
      left: 0;
      height: 32px;
      padding: 0;
      margin: 0;
      display: flex;
      align-items: stretch;
      border-bottom: 2px solid var(--color-lighter-background);
      -webkit-user-select: none;
      display: flex;
    }
    :scope > div.tab-bar div.tab {
      padding: 4px 20px;
      cursor: pointer;
      border-top: 4px solid transparent;
    }
    :scope > div.tab-bar div.tab.selected {
      border-top-color: var(--color-variables);
    }
  </style>

  <script>
    const {Layout} = require('dripcap');

    this.activeIndex = 0;
    this.items = opts.items || [
      {center: {tag: 'drip-tab2'}, name: 'TTT'},
      {center: {tag: 'drip-tab'}, name: 'TTTx'}
    ];

    setIndex(e) {
      this.activeIndex = e.item.i;
      e.preventUpdate = true;
      this.update();
    }

    setIndexKey(e) {
      if (e.code == 'Enter') {
        this.setIndex(e);
      }
    }

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
      if (this.activeIndex >= this.items.length) {
        this.activeIndex = this.items.length - 1;
      }
    });

    this.on('mount', () => {
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
</drip-tab-view>
