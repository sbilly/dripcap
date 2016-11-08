<packet-filter-view>
  <input class="compact" type="text" placeholder="Filter" name="filter" onkeypress={apply}>
  <div class="acview popup"> CANDIDATE </div>

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

    this.apply = e => {
      if (e.charCode === 13) {
        PubSub.pub('packet-filter-view:filter', $(this.filter).val());
      }
      return true;
    };

    this.on('update ', () => {
      let acview = $('.acview');
      $('input[name=filter]').on('input', function() {
        let coordinates = caret(this, this.selectionEnd);
        acview.css('left', coordinates.left);
      });
    });

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
