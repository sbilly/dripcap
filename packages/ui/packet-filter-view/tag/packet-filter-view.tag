<packet-filter-view>
  <input class="compact" type="text" placeholder="Filter" name="filter" onkeypress={apply}>
  <div class="acview popup">
    <ul>
      <li each={ c in candidates }>
        {c}
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

      .acview {
        width: 320px;
        height: 100px;
        position: absolute;
        padding: 10px;
        bottom: 48px;
        color: #fff;
        z-index: 1;
        border-radius: 5px;
        border-style: solid;
        display: none;
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

    this.apply = e => {
      if (e.charCode === 13) {
        this.acview.hide();
        this.fixed = true;
        PubSub.pub('packet-filter-view:filter', $(this.filter).val());
      }
      return true;
    };

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

    let candidates = [
      'ipv4.pyalod',
      'eth.pyalod',
      'tcp',
      'ipv4',
      'eth'
    ]
    candidates.sort();

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
            if (key.startsWith(keyword)) {
              this.candidates.push(key);
            }
          }
        }

        if (this.candidates.length) {
          this.update();
          this.acview.show();
        } else {
          this.acview.hide();
        }
      } else {
        this.acview.hide();
      }
    };

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
