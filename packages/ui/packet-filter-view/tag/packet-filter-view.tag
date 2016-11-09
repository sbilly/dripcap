<packet-filter-view>
  <input class="compact" type="text" placeholder="Filter" name="filter" onkeypress={apply} onkeydown={apply}>
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

        span {
          opacity: 0.6;
          float: right;
          font-size: 0.9em;
        }
      }

      .acview {
        width: 420px;
        height: 100px;
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
      }
    }
  </style>

  <script>
    import $ from 'jquery';
    import { Session, PubSub } from 'dripcap';
    import caret from 'textarea-caret';

    PubSub.sub('packet-filter-view:set-filter', (text) => {
      $(this.filter).val(text);
      PubSub.pub('packet-filter-view:filter', text);
    });

    this.candidates = [];
    this.fixed = false;
    this.index = -1;

    this.apply = e => {
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
          return false;
        }
        break;
      case 'Enter':
        let value = $(this.filter).val();
        this.index = -1;
        this.acview.hide();
        if (value.length) this.fixed = true;
        PubSub.pub('packet-filter-view:filter', value);
      }
      return true;
    };

    this.clickCandidate = e => {
      this.select(e.item.c.filter);
      this.input.focus();
    }

    this.select = (value) => {
      this.acview.hide();
      let text = this.input.val();
      let cur = text.lastIndexOf(' ');
      this.input.val(text.substring(0, (cur >= 0 ? cur + 1 : 0)) + value);
    }

    this.on('mount', () => {
      $(() => {
        this.acview = $('.acview');
        this.input = $('input[name=filter]');
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
        this.input.blur(this.reload);
      });
    });

    let candidates = []
    PubSub.sub('core:filter-hints', (hints) => {
      candidates = hints;
    });

    this.reload = () => {
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
          this.candidates = candidates;
        } else {
          for (let key of candidates) {
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

    this.updateCursor = () => {
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

    this.updateCandidates = list => {
      if (list.length) {

      } else {

      }
    };

    Session.on('created', session => {
      PubSub.sub('packet-filter-view:filter', filter => session.filter('main', filter));
    });
  </script>
</packet-filter-view>
