<drip-tab>
  <a>tttt</a>
</drip-tab>

<drip-tab2>
  <a>ttttddddddd<br>b</a>
    <a>ttttddddddd<br>b</a>
      <a>ttttddddddd<br>b</a>
        <a>ttttddddddd<br>b</a>
          <a>ttttddddddd<br>b</a>
            <a>ttttddddddd<br>b</a>
              <a>ttttddddddd<br>b</a>
                <a>ttttddddddd<br>b</a>
                  <a>ttttddddddd<br>b</a>
                    <a>ttttddddddd<br>b</a>
                      <a>ttttddddddd<br>b</a>
                        <a>ttttddddddd<br>b</a>
                          <a>ttttddddddd<br>b</a>
                            <a>ttttddddddd<br>b</a>
                              <a>ttttddddddd<br>b</a>
                                <a>ttttddddddd<br>b</a>
                                  <a>ttttddddddd<br>b</a>
                                    <a>ttttddddddd<br>b</a>
</drip-tab2>

<drip-content-right2>
  <drip-vsplitter>
    <yield to="top">
      <drip-tab-view data-container-id="drip-tab-top"></drip-tab-view>
    </yield>
    <yield to="bottom">
      <drip-tab-view data-container-id="drip-tab-bottom"></drip-tab-view>
    </yield>
  </drip-vsplitter>
</drip-content-right2>

<drip-content-right>
  <drip-hsplitter width="420">
    <yield to="left">
      <drip-tab-view data-container-id="drip-tab-list"></drip-tab-view>
    </yield>
    <yield to="right">
      <virtual data-is="drip-content-right2"></virtual>
    </yield>
  </drip-hsplitter>
</drip-content-right>

<drip-content-root>
  <drip-hsplitter width="200">
    <yield to="left">
      <drip-session-list class={ darwin: process.platform == 'darwin' }></drip-session-list>
    </yield>
    <yield to="right">
      <virtual data-is="drip-content-right"></virtual>
    </yield>
  </drip-hsplitter>
  <drip-modal-view data-container-id="drip-modal"></drip-modal-view>
  <style type="text/less">
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

    select {
      padding: 0.5em 1em 0.5em 0.75em;
    }

    ::-webkit-scrollbar {
      width: 6px;
      background: var(--color-lighter-background);
    }
    ::-webkit-scrollbar:horizontal {
      height: 6px;
    }
    ::-webkit-scrollbar-piece {
      background: var(--color-lighter-background);
    }
    ::-webkit-scrollbar-piece:start {
      background: var(--color-lighter-background);
    }
    ::-webkit-scrollbar-thumb {
      background: var(--color-selection-background);
      min-height: 50px;
    }
    ::-webkit-scrollbar-corner {
      background: var(--color-selection-background);
    }

    input,
    select,
    textarea {
      border-radius: 2px;
      padding: 0.5em;
      line-height: 1.2em;
      width: 100%;
    }
    input[type="number"],
    input[type="text"] {
      box-sizing: border-box;
    }
    input[type=checkbox],
    input[type=radio] {
      display: inline-block;
      line-height: 1em;
      margin: 0 0.25em 0 0;
      padding: 0;
      width: 1.25em;
      height: 1.25em;
      border-radius: 0.25em;
      vertical-align: text-top;
    }
    input[type=number]::-webkit-inner-spin-button,
    input[type=number]::-webkit-outer-spin-button {
      -webkit-appearance: none;
      margin: 0;
    }
    a {
      color: inherit;
      text-decoration: none;
    }
    input[type=button] {
      height: 50px;
    }

    ::selection {
      background: var(--color-selection-background);
      color: var(--color-default-foreground);
    }
    // headline
    h1,
    h2,
    h3,
    h4,
    h5,
    h6 {
      color: var(--color-light-foreground);
    }
    th {
      color: var(--color-dark-foreground);
    }
    label {
      color: var(--color-dark-foreground);
    }
    // form
    select {
      background: var(--color-lighter-background);
    }
    input,
    select,
    textarea {
      border: 1px solid var(--color-selection-background);
      background: var(--color-lighter-background);
      color: var(--color-default-foreground);
    }
    input[type=checkbox]:checked {
      background-color: var(--color-variables);
    }

    * {
      outline-color: var(--color-variables);
    }

    ::-webkit-input-placeholder {
      color: var(--color-dark-foreground);
      opacity: 0.5;
    }

    :scope {
      position: absolute;
      top: 0;
      right: 0;
      left: 0;
      bottom: 0;
      margin: 0;
      padding: 0;
      -webkit-app-region: drag;
      color: var(--color-dark-foreground);

      drip-session-list {
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        right: 0;
        background-color: var(--color-default-background);
      }

      .darwin {
        margin-top: 42px;
        background-color: transparent;
      }

      > drip-hsplitter {
        position: absolute;
        top: 0;
        right: 0;
        left: 0;
        bottom: 0;
      }

      > drip-hsplitter > drip-splitter-content:last-child {
        background-color: var(--color-default-background);
      }

      > drip-modal-view {
        position: absolute;
        top: 0;
        right: 0;
        left: 0;
        bottom: 0;
      }
    }
  </style>
</drip-content-root>
