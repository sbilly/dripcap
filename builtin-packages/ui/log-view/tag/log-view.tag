<log-view-item>
  <li onclick={ toggle }>
    <i class="fa fa-circle-o" show={ !data }></i>
    <i class="fa fa-arrow-circle-right" show={ data && !show }></i>
    <i class="fa fa-arrow-circle-down" show={ data && show }></i>
    <span class="text-{level}">[{this.date}] {message}</span>
    <ul if={ data && data.resourceName } show={ show }>
      <li>
        { data.resourceName }
      </li>
      <li if={ data.lineNumber >= 0 }>
        Line: { data.lineNumber } Column: { data.startColumn }
      </li>
      <li if={ data.sourceLine }>
        { data.sourceLine }
      </li>
    </ul>
  </li>

  <script>
    this.show = false;

    this.on('mount', () => {
      let hours = ('0' + this.timestamp.getHours()).slice(-2);
      let minutes = ('0' + this.timestamp.getMinutes()).slice(-2);
      let seconds = ('0' + this.timestamp.getSeconds()).slice(-2);
      this.date = `${hours}:${minutes}:${seconds}`;
      this.update();
    });

    this.toggle = e => {
      if (opts.data) {
        this.show = !this.show;
      }
      e.stopPropagation();
    };
  </script>
</log-view-item>

<log-view-filter>
  <select>
    <option>Filter: All</option>
  </select>
</log-view-filter>

<log-view>
  <ul>
    <log-view-item each={ logs } data={ this }></log-view-item>
  </ul>

  <script>
    const { PubSub } = require('dripcap');
    this.logs = [];

    this.on('mount', () => {
      PubSub.sub(this, 'core:log', (log) => {
        this.logs.push(log);
        this.update();
      });
    });

    this.on('unmount', () => {
      PubSub.removeHolder(this);
    });
  </script>

  <style type="text/less">
    :scope {
      ul {
        padding-left: 20px;
        -webkit-user-select: text;
      }
      li {
        white-space: normal;
        list-style: none;
        padding: 4px;

        span {
          margin-right: 8px;
        }
      }
    }
  </style>
</log-view>
