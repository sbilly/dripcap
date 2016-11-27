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
      background-color: var(--color-selection-background);
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
      e.preventUpdate = true;
      return false;
    }

    shouldUpdate(force) {
      return !this.dragging || force;
    }

    updateRatio(ratio) {
      if (ratio >= 0.05 && ratio <= 0.95) {
        $(this.root).css('grid-template-rows', `${ratio*100}fr 2px ${(1-ratio)*100}fr`);
      }
    }

    startDrag() {
      this.dragging = true;
      this.update(true);
      return false;
    }

    stopDrag() {
      this.dragging = false;
      this.update(true);
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

    shouldUpdate(force) {
      return !this.dragging || force;
    }

    move(e) {
      let $this = $(this.root);
      let left = $this.offset().left;
      let width = $this.width();
      if (this.dragging) {
        this.updateRatio((e.clientX - left) / width);
      }
      e.preventUpdate = true;
      return false;
    }

    updateRatio(ratio) {
      if (ratio >= 0.05 && ratio <= 0.95) {
        $(this.root).css('grid-template-columns', `${ratio*100}fr 2px ${(1-ratio)*100}fr`);
      }
    }

    startDrag() {
      this.dragging = true;
      this.update(true);
      return false;
    }

    stopDrag() {
      this.dragging = false;
      this.update(true);
      return false;
    }
  </script>
</drip-hsplitter>
