<drip-session-list>
  <ul>
    <li each={ sess, i in sessions } class={ session: true, selected: i == activeIndex } onclick={ setIndex }>
      <i class={ fa: true, fa-cog: true, fa-spin: status.get(sess).capturing }></i>
      { sess.interface } <span>{ status.get(sess).packets }</span>
    </li>
    <li class="button"><i class="fa fa-plus"></i> New Session</li>
  </ul>

  <style>
    :scope > ul {
      padding: 0;
      margin: 0;
      -webkit-user-select: none;
    }

    :scope > ul > li {
      list-style: none;
      padding: 10px 10px;
      margin: 3px 0;
      cursor: pointer;
    }

    :scope > ul > li.selected {
      background-color: var(--color-selection-background);
    }

    :scope > ul > li.session {
      border-left: 5px solid var(--color-selection-background);
    }

    :scope > ul > li.session > span {
      border-radius: 15px;
      background-color: var(--color-variables);
      padding: 0 8px;
      float: right;
    }

    :scope > ul > li.button {
      border-left: 5px solid transparent;
      color: var(--color-default-background);
      background-color: var(--color-functions);
    }
  </style>

  <script>
    const {PubSub} = require('dripcap');
    this.sessions = [];
    this.status = new WeakMap();
    this.activeIndex = -1;

    setIndex(e) {
      this._setIndex(e.item.i);
    }

    _setIndex(index) {
      if (this.activeIndex != index) {
        this.activeIndex = index;
        PubSub.pub('core:session-selected', this.sessions[index]);
      }
    }

    PubSub.on('core:session-added', (sess) => {
      this.sessions.push(sess);
      this.status.set(sess, {capturing: false, packets: 0});
      sess.on('status', (stat) => {
        this.status.set(sess, stat);
        this.update();
      });
      if (this.activeIndex < 0) this._setIndex(0);
      this.update();
    });

    PubSub.on('core:session-removed', (sess) => {
      let index = this.sessions.indexOf(sess);
      if (index >= 0) {
        this.sessions[index].removeAllListeners();
        this.sessions.splice(index, 1);
        if (this.activeIndex >= this.sessions.length)
          this._setIndex(this.sessions.length - 1);
        this.update();
      }
    });

  </script>
</drip-session-list>
