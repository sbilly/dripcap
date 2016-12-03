<packet-list-view>

  <div class="main"></div>

  <script>
    const $ = require('jquery');
    const { PubSub } = require('dripcap');

    this.on('mount', () => {
      this.main = $(this.root).children('div.main');

      PubSub.sub(this, 'core:theme-id-updated', () => {
        let computed = getComputedStyle(document.documentElement);
        let color = computed.getPropertyValue('--color-lighter-background');

        let canvas = $("<canvas width='64' height='64'>")[0];
        let ctx = canvas.getContext("2d");
        ctx.fillStyle = color;
        ctx.fillRect(0, 0, 64, 32);
        this.main.css('background-image', `url(${canvas.toDataURL('image/png')})`);
      });

      PubSub.sub(this, 'core:session-added', sess => {
        this.session = sess;
        this.packets = 0;
        this.filtered = -1;
        this.selectedId = -1;
        this.reset();
        this.reload();
        process.nextTick(() => {
          $(this.root).focus();
        });
        sess.on('status',(n) => {
          if (n.packets < this.packets) {
            this.reset();
          }
          this.packets = n.packets;
          if (n.filtered.main != null) {
            this.filtered = n.filtered.main;
          } else {
            this.filtered = -1;
          }
          this.reload();
        });
      });

      this.reset();
    });

    this.on('unmount', () => {
      PubSub.removeHolder(this);
    });

    reset() {
      this.prevStart = -1;
      this.prevEnd = -1;
      this.main.empty();
      this.cells = $([]);
    }

    reload() {
      let margin = 5;
      let height = 32;

      let num = this.packets;
      if (this.filtered !== -1) {
        num = this.filtered;
      }

      /*
      if (num > 0 && this.view.height() === 0) {
        setTimeout(() => {
          this.update();
        }, 500);
      }
      */

      this.main.css('height', (height * num) + 'px');
      /*
      let start = Math.max(1, Math.floor((this.root.scrollTop() / height) - margin));
      let end = Math.min(num, Math.floor(((this.root.scrollTop() + this.root.height()) / height) + margin));
      */
    }

  </script>

  <style type="text/less" scoped>
    :scope {
      outline-offset: -5px;
      div.main {
        align-self: stretch;
        border-spacing: 0;
        table-layout: fixed;
        width: 100%;
        div.packet {
          width: 100%;
          height: 32px;
          position: absolute;
          display: flex;
          align-items: center;
          a {
            text-decoration: none;
            flex-grow: 1;
            padding-left: 15px;
            cursor: default;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            width: 0;
          }
          a:nth-child(2),
          a:nth-child(4) {
            flex-grow: 4;
          }
          a:nth-child(3) {
            flex-grow: 0.5;
            text-align: center;
          }
        }
      }
    }
  </style>
</packet-list-view>
