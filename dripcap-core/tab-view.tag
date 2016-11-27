<drip-tab-view>
  <div class="tab-bar" show={ items.length > 1 }>
    <div each={ item, i in items }  class={ tab: true, selected: i == this.activeIndex } onclick={ setIndex }> { item.name } </div>
  </div>
  <virtual each={ item, i in items }>
    <drip-grid-container item={ item } show={ i == this.activeIndex } class={ show-tab: items.length > 1 }></drip-grid-container>
  </virtual>
  <style>
    :scope {
      display: grid;
      grid-template-columns: 1fr;
      grid-template-rows: 32px 1fr;
    }
    :scope > div {
      grid-column: 1 / 1;
      grid-row: 1 / 3;
    }
    :scope > drip-grid-container.show-tab {
      grid-row: 2 / 3;
    }
    :scope > div.tab-bar {
      grid-row: 1 / 2;
      padding: 0;
      margin: 0;
      display: flex;
      align-items: stretch;
      border-bottom: 2px solid var(--background2);
      -webkit-user-select: none;
      display: flex;
    }
    :scope > div.tab-bar div.tab {
      padding: 4px 20px;
      cursor: pointer;
      border-top: 4px solid transparent;
    }
    :scope > div.tab-bar div.tab.selected {
      border-top-color: var(--color1);
    }
  </style>

  <script>
    const {Layout} = require('dripcap');

    this.activeIndex = 0;
    this.items = [
      {center: {tag: 'drip-tab', id: "acaaa"}, name: "aaa", id: "aaaa"},
      {center: {tag: 'drip-tab2', id: "xxaaaa"}, name: 'bbb', id: "bb"}
    ];

    setIndex(e) {
      this.activeIndex = e.item.i;
    }

    _append(item) {
      this.items.push(item);
      this.update();
    }

    _remove(id) {
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
        Layout.registerContainer(opts.dataContainerId, (function (view) {
          return {
            append: view._append,
            remove: view._remove,
          };
        })(this));
      }
    });
    this.on('unmount', () => {
      if (opts.dataContainerId) {
        Layout.unregisterContainer(opts.dataContainerId);
      }
    });
  </script>
</drip-tab-view>
