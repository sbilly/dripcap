<packet-list-view>

  <div class="main"></div>

  <script>
    const $ = require('jquery');
    const { PubSub } = require('dripcap');

    this.on('mount', () => {
      this.view = $(this.root);
      this.main = this.view.children('div.main');
      this.updateStatus = (n) => {
        if (n.packets < this.packets) {
          this.reset();
        }
        this.packets = n.packets;
        if (n.filtered && n.filtered.main != null) {
          this.filtered = n.filtered.main;
        } else {
          this.filtered = -1;
        }
        this.reload();
      };

      PubSub.sub(this, 'core:theme-id-updated', () => {
        let computed = getComputedStyle(document.documentElement);
        let canvas = $("<canvas width='64' height='64'>")[0];
        let ctx = canvas.getContext("2d");
        ctx.fillStyle = computed.getPropertyValue('--color-lighter-background');
        ctx.fillRect(0, 0, 64, 32);
        ctx.fillStyle = computed.getPropertyValue('--color-default-background');
        ctx.fillRect(0, 32, 64, 32);
        this.main.css('background-image', `url(${canvas.toDataURL('image/png')})`);
      });

      PubSub.sub(this, 'packet-filter-view:filter', filter => {
        this.filtered = 0;
        this.reset();
        this.reload();
      });

      PubSub.sub(this, 'core:session-removed', sess => {
        if (this.session === sess) {
          sess.removeListener('status', this.updateStatus);
          this.session = null;
          this.reset();
          this.reload();
        }
      });

      PubSub.sub(this, 'core:session-selected', (data) => {
        let sess = data.session;
        let status = data.status;
        if (this.session === sess) {
          return;
        }
        if (this.session)
          this.session.removeListener('status', this.updateStatus);

        this.session = sess;
        this.packets = 0;
        this.filtered = -1;
        this.selectedId = -1;
        this.reset();
        this.reload();
        process.nextTick(() => {
          $(this.root).focus();
        });
        sess.on('status', this.updateStatus);
        if (status) this.updateStatus(status);
      });

      this.reset();
    });

    this.on('unmount', () => {
      PubSub.removeHolder(this);
    });

    reset() {
      this.prevStart = -1;
      this.prevEnd = -1;
      this.main.empty().css('height', '0');
      this.cells = $([]);
    }

    reload() {
      let margin = 5;
      let height = 32;

      let num = this.packets;
      if (this.filtered !== -1) {
        num = this.filtered;
      }

      this.main.css('height', (height * num) + 'px');
      let start = Math.max(1, Math.floor((this.view.scrollTop() / height) - margin));
      let end = Math.min(num, Math.floor(((this.view.scrollTop() + this.view.height()) / height) + margin));

      this.cells.filter(':visible').each((i, ele) => {
        let pos = parseInt($(ele).css('top'));
        if (pos + $(ele).height() + (margin * height) < this.view.scrollTop() || pos - (margin * height) > this.view.scrollTop() + this.view.height()) {
          $(ele).hide();
        }
      });

      if (this.prevStart !== start || this.prevEnd !== end) {
        this.prevStart = start;
        this.prevEnd = end;
        if ((this.session != null) && start <= end) {
          if (this.filtered === -1) {
            let list = [];
            for (let i = start; i <= end; ++i) {
              list.push(i);
            }
            this.updateCells(start - 1, list);
          } else {
            let list = this.session.getFiltered('main', start - 1, end - 1);
            this.updateCells(start - 1, list);
          }
        }
      }
    }

    updateCells(start, list) {
      let packets = [];
      let indices = [];
      for (let n = 0; n < list.length; n++) {
        let id = list[n];
        if (!this.cells.is(`[data-packet=${id}]:visible`)) {
          packets.push(id);
          indices.push(start + n);
        }
      }

      let needed = packets.length - this.cells.filter(':not(:visible)').length;
      if (needed > 0) {
        for (let i = 1; i <= needed; ++i) {
          let self = this;
          $('<div class="packet list-item">').appendTo(this.main).hide().click(function() {
            $(this).siblings('.selected').removeClass('selected');
            $(this).addClass('selected');
            self.selectedId = parseInt($(this).attr('data-packet'));
            process.nextTick(() => {
              PubSub.pub('core:session-packet', self.session.get(self.selectedId));
            });
          });
        }

        this.cells = this.main.children('div.packet');
      }

      this.cells.filter(':not(:visible)').each((i, ele) => {
        if (i >= packets.length) {
          return;
        }
        let id = packets[i];
        $(ele).attr('data-packet', id).toggleClass('selected', this.selectedId === id).empty().css('top', (32 * indices[i]) + 'px').show();
      });

      for (let id of packets) {
        let pkt = this.session.get(id);
        if (pkt.seq === this.selectedId) {
          PubSub.pub('packet-list-view:select', pkt);
        }
        process.nextTick(() => {
          this.cells.filter(`[data-packet=${pkt.seq}]:visible`)
            .empty()
            .append($('<a>').text(pkt.name))
            .append($('<a>').text('?'))
            .append($('<a>').append($('<i class="fa fa-angle-double-right">')))
            .append($('<a>').text('?'))
            .append($('<a>').text(pkt.length));
        });
      }
    }

  </script>

  <style type="text/less">
    :scope {
      outline-offset: -5px;
      div.main {
        align-self: stretch;
        border-spacing: 0;
        table-layout: fixed;
        width: 100%;
        div.packet {
          position: absolute;
          height: 32px;
          left :0;
          right: 0;
          display: flex;
          align-items: center;
          border-left: 5px solid transparent;
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
          &.selected {
            color: var(--color-default-background);
            background-color: var(--color-variables);
          }
          &:hover {
            border-left-color: var(--color-variables);
          }
        }
      }
    }
  </style>
</packet-list-view>
