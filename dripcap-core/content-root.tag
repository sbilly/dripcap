<drip-content-root>
  <aside></aside>
  <drip-hsplitter ratio="0.4">
    <yield to="left">
      My beautiful post is just awesome
    </yield>
    <yield to="right">
      <drip-vsplitter>
        <yield to="top">
          My beautiful post is just awesome
        </yield>
        <yield to="bottom">
          !My beautiful post is just awesome
        </yield>
      </drip-vsplitter>
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
