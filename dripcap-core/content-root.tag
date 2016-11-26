<drip-splitter-content>
  <yield/>
  <style>
    :scope {
      display: grid;
    }
  </style>
</drip-splitter-content>

<drip-splitter-bar>
  <style>
    :scope {
      background-color: var(--background2);
      -webkit-app-region: no-drag;
    }
  </style>
</drip-splitter-bar>

<drip-splitter-dragarea>
<style>
  :scope {
    -webkit-app-region: no-drag;
  }
</style>
</drip-splitter-dragarea>

<drip-vsplitter>
  <drip-splitter-content>
    <yield from="top"/>
  </drip-splitter-content>
  <drip-splitter-bar onmousedown={ startDrag } onmouseup={ stopDrag }></drip-splitter-bar>
  <drip-splitter-dragarea show={ dragging } onmouseup={ stopDrag } onmouseout={ stopDrag } onmousemove={ move }></drip-splitter-dragarea>
  <drip-splitter-content>
    <yield from="bottom"/>
  </drip-splitter-content>
  <style>
    :scope {
      display: grid;
      grid-template-columns: 1fr;
      grid-template-areas: "top"
                           "center"
                           "bottom";
    }

    :scope > drip-splitter-content:first-child {
      grid-area: top;
    }

    :scope > drip-splitter-bar {
      grid-area: center;
      cursor: row-resize;
    }

    :scope > drip-splitter-dragarea {
      grid-column: 1 / 1;
      grid-row: row1-start / 1;
      cursor: row-resize;
      z-index: 1;
    }

    :scope > drip-splitter-content:last-child {
      grid-area: bottom;
    }
  </style>

  <script>
    this.dragging = false;
    const $ = require('jquery');

    this.on('mount', () => {
      this.updateRatio(opts.ratio || 0.5);
    });

    move(e) {
      let $this = $(this.root);
      let top = $this.offset().top;
      let height = $this.height();
      if (this.dragging) {
        this.updateRatio((e.clientY - top) / height);
      }
      return false;
    }

    updateRatio(ratio) {
      if (ratio >= 0.05 && ratio <= 0.95) {
        $(this.root).css('grid-template-rows', `${ratio*100}fr 2px ${(1-ratio)*100}fr`);
      }
    }

    startDrag() {
      this.dragging = true;
      return false;
    }

    stopDrag() {
      this.dragging = false;
      return false;
    }
  </script>
</drip-vsplitter>

<drip-hsplitter>
  <drip-splitter-content>
    <yield from="left"/>
  </drip-splitter-content>
  <drip-splitter-bar onmousedown={ startDrag } onmouseup={ stopDrag }></drip-splitter-bar>
  <drip-splitter-dragarea show={ dragging } onmouseup={ stopDrag } onmouseout={ stopDrag } onmousemove={ move }></drip-splitter-dragarea>
  <drip-splitter-content>
    <yield from="right"/>
  </drip-splitter-content>
  <style>
    :scope {
      display: grid;
      grid-template-rows: 1fr;
      grid-template-areas: "left center right";
    }

    :scope > drip-splitter-content:first-child {
      grid-area: left;
    }

    :scope > drip-splitter-bar {
      grid-area: center;
      cursor: col-resize;
    }

    :scope > drip-splitter-dragarea {
      grid-row: 1 / 1;
      grid-column: column1-start / 1;
      cursor: col-resize;
      z-index: 1;
    }

    :scope > drip-splitter-content:last-child {
      grid-area: right;
    }
  </style>

  <script>
    this.dragging = false;
    const $ = require('jquery');

    this.on('mount', () => {
      this.updateRatio(opts.ratio || 0.5);
    });

    move(e) {
      let $this = $(this.root);
      let left = $this.offset().left;
      let width = $this.width();
      if (this.dragging) {
        this.updateRatio((e.clientX - left) / width);
      }
      return false;
    }

    updateRatio(ratio) {
      if (ratio >= 0.05 && ratio <= 0.95) {
        $(this.root).css('grid-template-columns', `${ratio*100}fr 2px ${(1-ratio)*100}fr`);
      }
    }

    startDrag() {
      this.dragging = true;
      return false;
    }

    stopDrag() {
      this.dragging = false;
      return false;
    }
  </script>
</drip-hsplitter>

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
