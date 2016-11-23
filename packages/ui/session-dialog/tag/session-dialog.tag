<session-dialog>

  <modal-dialog>
    <h2>New session</h2>
    <p>
      <select name="interface">
        <option each={ parent.interfaceList } if={ link===1 } value={ encodeURI(id) }>{ name }</option>
      </select>
    </p>
    <p>
      <input type="text" name="filter" placeholder="filter (BPF)">
    </p>
    <p>
      <label>
        <input type="checkbox" name="promisc">
        Promiscuous mode
      </label>
    </p>
    <p>
      <input type="button" name="start" value="Start" onclick={ parent.start }>
    </p>
  </modal-dialog>

  <style type="text/less" scoped>
    :scope > modal-dialog > .modal > .content {
      max-width: 600px;
    }
  </style>

  <script>
    import $ from 'jquery';
    import { Session, PubSub, Profile, Logger } from 'dripcap-core';

    this.setInterfaceList = list => {
      return this.interfaceList = list;
    };

    this.show = () => {
      return this.tags['modal-dialog'].show();
    };

    this.start = () => {
      let ifs = decodeURI($(this.tags['modal-dialog'].interface).val());
      let filter = $(this.tags['modal-dialog'].filter).val();
      let promisc = $(this.tags['modal-dialog'].promisc).prop('checked');
      let snaplen = Profile.getConfig('snaplen');

      this.tags['modal-dialog'].hide();
      Session.create(ifs, {
        filter: filter,
        promiscuous: promisc,
        snaplen: snaplen
      }).then(sess => {
        for (let err of sess.errors) {
          Logger.error(err.message);
        }
        PubSub.pub('core:session-created', sess);
        sess.on('status', stat => {
          PubSub.pub('core:capturing-status', stat);
        });
        sess.on('log', log => {
          PubSub.pub('core:log', {
            level: log.level,
            message: log.message,
            timestamp: new Date(),
            data: log.data
          });
        });
        if (Session.list != null) {
          for (let i = 0; i < Session.list.length; i++) {
            let s = Session.list[i];
            s.close();
          }
        }
        Session.list = [sess];
        Session.emit('created', sess);
        sess.start();
      });
    };
  </script>

</session-dialog>
