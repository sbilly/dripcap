<drip-tab>
  <a>tttt</a>
</drip-tab>

<drip-tab2>
  <a>ttttddddddd</a>
</drip-tab2>

<drip-container>
  <div>
     <div data-is={ opts.item.tag }></div>
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
</drip-container>

<drip-tab-view>
  <div class="tab-bar" show={ items.length > 1 }>
    <div each={ item, i in items }  class={ tab: true, selected: i == this.activeIndex } onclick={ setIndex }> { item.name } </div>
  </div>
  <virtual each={ item, i in items }>
    <drip-container item={ item } show={ i == this.activeIndex } class={ show-tab: items.length > 1 }></drip-container>
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
    :scope > drip-container.show-tab {
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
      {tag: 'drip-tab', name: "aaa", id: "aaaa"},
      {tag: 'drip-tab2', name: 'bbb', id: "bb"}
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

<drip-content-right>
  <drip-vsplitter>
    <yield to="top">
      <drip-tab-view data-container-id="drip-tab-top"></drip-tab-view>
    </yield>
    <yield to="bottom">
      <drip-tab-view data-container-id="drip-tab-bottom"></drip-tab-view>
    </yield>
  </drip-vsplitter>
</drip-content-right>

<drip-content-root>
  <aside></aside>
  <drip-hsplitter ratio="0.4">
    <yield to="left">
      <drip-tab-view data-container-id="drip-tab-list"></drip-tab-view>
    </yield>
    <yield to="right">
      <virtual data-is="drip-content-right"></virtual>
    </yield>
  </drip-hsplitter>
  <style>
    * {
      font-family: 'Lucida Grande', 'Segoe UI', Ubuntu, Cantarell, 'Droid Sans Fallback', sans-serif;
      font-size: 14px;
    }

    .fa {
      font-family: 'FontAwesome', 'Lucida Grande', 'Segoe UI', Ubuntu, Cantarell, 'Droid Sans Fallback', sans-serif;
    }

    * {
      -webkit-appearance: none;
    }

    html {
      overflow: hidden;
      height: 100%;
    }

    body {
      -webkit-user-select: none;
      height: 100%;
      overflow: hidden;
    }

    :scope {
      position: absolute;
      top: 0;
      right: 0;
      left: 0;
      bottom: 0;
      margin: 0;
      padding: 0;
      display: grid;
      grid-template-columns: 140px 1fr;
      grid-template-rows: 1fr;
      grid-template-areas: "side body";
      -webkit-app-region: drag;
      color: var(--foreground1);
    }

    :scope > aside {
      grid-area: side;
    }

    :scope > drip-hsplitter {
      grid-area: body;
      background-color: var(--background1);
    }
  </style>
</drip-content-root>
