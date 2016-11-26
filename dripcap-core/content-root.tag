<drip-tab>
  <a>tttt</a>
</drip-tab>

<drip-tab2>
  <a>ttttddddddd</a>
</drip-tab2>

<drip-tab-view>
  <virtual each={ item in items }>
    <div data-is={ item.tag } class={ show-tab: items.length > 1 }></div>
  </virtual>
  <style>
    :scope {
      display: grid;
      grid-template-columns: 1fr;
      grid-template-rows: 24px 1fr;
    }
    :scope > div {
      grid-column: 1 / 1;
      grid-row: 1 / 3;
    }
    :scope > div.show-tab {
      grid-row: 2 / 3;
    }
  </style>

  <script>
    this.items = [
      {tag: 'drip-tab'},
      {tag: 'drip-tab2'}
    ];
  </script>
</drip-tab-view>

<drip-content-right>
  <drip-vsplitter>
    <yield to="top">
      <drip-tab-view data-view-id="drip-top"></drip-tab-view>
    </yield>
    <yield to="bottom">
      <drip-tab-view data-view-id="drip-bottom"></drip-tab-view>
    </yield>
  </drip-vsplitter>
</drip-content-right>

<drip-content-root>
  <aside></aside>
  <drip-hsplitter ratio="0.4">
    <yield to="left">
      My beautiful post is just awesome
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
      overflow: auto;
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
