<packet-filter-view>
  <input class="compact" type="text" placeholder="Filter" ref="filter" onkeypress={apply} onkeydown={apply}>
  <div class="acview popup">
    <ul>
      <li each={ c, i in candidates } class={ list-item: true, selected: i === parent.index } onclick={ parent.clickCandidate }>
        {c.filter}
        <span>{c.description}</span>
      </li>
    </ul>
  </div>

  <style type="text/less" scoped>
    :scope {
      input {
        border-right-width: 0;
        border-left-width: 0;
        border-bottom-width: 0;
      }

      ul {
        padding: 0;
        margin: 0;
      }

      li {
        white-space: nowrap;
        list-style: none;
        padding: 8px;
        margin: 0;
        cursor: default;
        border-left: 5px solid transparent;

        span {
          opacity: 0.6;
          float: right;
          font-size: 0.9em;
        }

        &.selected {
          color: var(--color-default-background);
          background-color: var(--color-variables);
        }

        &:hover {
          border-left-color: var(--color-variables);
        }
      }

      .acview {
        width: 90%;
        height: 220px;
        position: absolute;
        padding: 0;
        bottom: 48px;
        z-index: 1;
        border-radius: 5px;
        border-style: solid;
        display: none;
        overflow-y: scroll;
        overflow-x: hidden;
        box-shadow:0px 0px 17px 3px rgba(0,0,0,0.40);
        background-color: var(--color-default-background);
      }
    }
  </style>

  <script>
    const $ = require('jquery');
    const { Session, PubSub } = require('dripcap');
    const caret = require('textarea-caret');

    this.candidates = [];
    this.fixed = false;
    this.index = -1;
    this.sessions = new WeakMap();

    this.on('mount', () => {
      this.acview = $(this.root).find('.acview');
      this.input = $(this.refs.filter);
      this.input.on('input', () => {
        this.fixed = false;
        let cur = this.input.val().lastIndexOf(' ');
        this.acview.css('left', caret(this.input[0], cur >= 0 ? cur : 0).left);
        this.reload();
      })
      this.acview.css('left', '7px');
      this.input.focus(() => {
        if (!this.fixed) this.reload();
      });
      this.input.blur(() => {
        setTimeout(() => {
          this.acview.hide();
        }, 100);
      });
      PubSub.sub(this, 'core:filter-hints', (hints) => {
        this.filterHints = hints;
      });
      PubSub.sub(this, 'packet-filter-view:set-filter', (text) => {
        $(this.refs.filter).val(text);
        PubSub.pub('packet-filter-view:filter', text);
      });

      PubSub.sub(this, 'packet-filter-view:filter', (filter) => {
        if (this.session) {
          this.session.filter('main', filter);
        }
      });

      PubSub.sub(this, 'core:session-selected', (data) => {
        let sess = data.session;
        this.session = sess;
        let value = $(this.refs.filter).val();
        if (value) {
          PubSub.pub('packet-filter-view:filter', value);
        }
      });
    });

    this.on('unmount', () => {
      PubSub.removeHolder(this);
    });

    apply(e) {
      switch (e.code) {
      case "ArrowUp":
        if (this.index >= 0) {
          this.index = (this.index + this.candidates.length - 1) % this.candidates.length;
          process.nextTick(() => this.updateCursor());
          return false;
        }
        break;
      case "ArrowDown":
        if (this.index >= 0) {
          this.index = (this.index + 1) % this.candidates.length;
          process.nextTick(() => this.updateCursor());
          return false;
        }
        break;
      case "Tab":
        if (this.index >= 0) {
          this.select(this.candidates[this.index].filter);
          e.preventDefault();
          return false;
        }
        break;
      case 'Enter':
        let value = $(this.refs.filter).val();
        this.index = -1;
        this.acview.hide();
        if (value.length) this.fixed = true;
        PubSub.pub('packet-filter-view:filter', value);
      }
      return true;
    }

    clickCandidate(e) {
      this.select(e.item.c.filter);
      this.fixed = true;
      setTimeout(() => {
        this.input.focus();
      }, 100);
    }

    select(value) {
      this.acview.hide();
      let text = this.input.val();
      let cur = text.lastIndexOf(' ');
      this.input.val(text.substring(0, (cur >= 0 ? cur + 1 : 0)) + value);
    }

    reload() {
      if (this.input.is(':focus')) {
        let text = this.input.val();
        let keyword = null;
        if (/(^|\s+)$/.test(text)) {
          keyword = '';
        } else {
          let m = text.match(/(\S+)$/);
          if (m) keyword = m[1];
        }

        this.candidates = [];
        if (keyword === '') {
          this.candidates = this.filterHints;
        } else {
          for (let key of this.filterHints) {
            if (key.filter.startsWith(keyword)) {
              this.candidates.push(key);
            }
          }
        }

        if (this.candidates.length) {
          this.index = this.candidates.length - 1;
          this.update();
          this.acview.show();
          this.updateCursor();
        } else {
          this.index = -1;
          this.acview.hide();
        }
      } else {
        this.index = -1;
        setTimeout(() => {
          this.acview.hide();
        }, 100);
      }
    };

    updateCursor() {
      if (this.index >= 0) {
        let selected = $('.acview li.selected');
        let height = selected.height() + 16;
        let top = this.index * height;
        let bottom = (this.index + 1) * height;
        if (top < this.acview.scrollTop()) {
          this.acview.scrollTop(top);
        } else if (bottom > this.acview.scrollTop() + this.acview.height()) {
          this.acview.scrollTop(bottom - this.acview.height());
        }
      }
    }
  </script>
</packet-filter-view>
