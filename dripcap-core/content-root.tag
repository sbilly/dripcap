<drip-tab>
  <a>tttt</a>
</drip-tab>

<drip-tab2>
  <a>ttttddddddd</a>
</drip-tab2>

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
