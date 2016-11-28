<drip-session-list>
  <ul>
    <li each={ sess, i in sessions } class={ selected: i == activeIndex } onclick={ setIndex }>{ sess.interface }</li>
  </ul>

  <style>
    :scope > ul {
      padding: 0;
    }

    :scope > ul > li {
      list-style: none;
      padding: 20px 10px;
      margin: 3px 0;
      border-left: 5px solid var(--color-selection-background);
    }

    :scope > ul > li.selected {
      background-color: var(--color-selection-background);
    }
  </style>

  <script>
    this.sessions = [];
    this.activeIndex = 0;

    setIndex(e) {
      this.activeIndex = e.item.i;
    }

    const {PubSub} = require('dripcap');
    PubSub.on('core:session-added', (sess) => {
      this.sessions.push(sess);
      this.update();
    });
  </script>
</drip-session-list>
