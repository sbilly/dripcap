<log-view-item>
  <li onclick={ toggle }>
    <i class="fa fa-circle-o" show={ !data }></i>
    <i class="fa fa-arrow-circle-right" show={ data && !show }></i>
    <i class="fa fa-arrow-circle-down" show={ data && show }></i>
    <span class="text-{level}">[{date}] {message}</span>
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
    this.logs = [
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'},
      {date: new Date(), message: 'aaa'}  
    ];
  </script>

  <style type="text/less" scoped>
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
