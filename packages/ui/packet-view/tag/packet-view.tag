<packet-view-dripcap-enum>
  <script>
    this.on('update', () => {
      let keys = Object.keys(opts.val).filter(k => !k.startsWith('_') && opts.val[k]);
      this.name = keys.length > 0 ? keys.join(', ') : '[Unknown]';
      if (opts.val._name) this.name = opts.val._name;
      this.value = opts.val._value;
    });
  </script>
  <i>{ name } ({value}) </i>
</packet-view-dripcap-enum>

<packet-view-dripcap-flags>
  <script>
    this.on('update', () => {
      let keys = Object.keys(opts.val).filter(k => !k.startsWith('_') && opts.val[k]);
      keys = keys.map(k => opts.val._name[k]);
      this.name = keys.length > 0 ? keys.join(', ') : '[None]';
      this.value = opts.val._value;
    });
  </script>
  <i>{ name } ({value}) </i>
</packet-view-dripcap-flags>

<packet-view-custom-value>
  <script>
    this.on('mount', () => {
      if (opts.tag != null) {
        riot.mount(this.root, opts.tag, {val: opts.val});
      }
    });
  </script>
</packet-view-custom-value>

<packet-view-boolean-value>
  <i class="fa fa-check-square-o" if={ opts.val }></i>
  <i class="fa fa-square-o" if={ !opts.val }></i>
</packet-view-boolean-value>

<packet-view-buffer-value>
  <i>{ opts.val.length } bytes</i>
</packet-view-buffer-value>

<packet-view-stream-value>
  <i>{ opts.val.length } bytes</i>
</packet-view-stream-value>

<packet-view-integer-value>
  <i if={ base==2 } oncontextmenu={ context }>
    <i class="base">0b</i>{ opts.val.toString(2) }</i>
  <i if={ base==8 } oncontextmenu={ context }>
    <i class="base">0</i>{ opts.val.toString(8) }</i>
  <i if={ base==10 } oncontextmenu={ context }>{ opts.val.toString(10) }</i>
  <i if={ base==16 } oncontextmenu={ context }>
    <i class="base">0x</i>{ opts.val.toString(16) }</i>
  <script>
    this.base = 10;

    this.context = e => {
      Menu.popup('packet-view:numeric-value-menu', this, remote.getCurrentWindow(), {event: e});
      e.stopPropagation();
    };
  </script>
</packet-view-integer-value>

<packet-view-string-value>
  <i></i>
  <script>
    import $ from 'jquery';

    this.on('update', () => {
      if (this.opts.val != null) {
        this.root.innerHTML = $('<div/>').text(this.opts.val.toString()).html();
      }
    });
  </script>
</packet-view-string-value>

<packet-view-item>
<li>
  <p class="label list-item" onclick={ toggle } range={ opts.field.range } oncontextmenu={ context } onmouseover={ fieldRange } onmouseout={ rangeOut }>
    <i class="fa fa-circle-o" show={ !opts.field.items.length }></i>
    <i class="fa fa-arrow-circle-right" show={ opts.field.items.length && !show }></i>
    <i class="fa fa-arrow-circle-down" show={ opts.field.items.length && show }></i>
    <a class="text-label">{ opts.field.name }</a>
    <packet-view-boolean-value if={ type=='boolean' } val={ val }></packet-view-boolean-value>
    <packet-view-integer-value if={ type=='integer' } val={ val }></packet-view-integer-value>
    <packet-view-string-value if={ type=='string' } val={ val }></packet-view-string-value>
    <packet-view-buffer-value if={ type=='buffer' } val={ val }></packet-view-buffer-value>
    <packet-view-stream-value if={ type=='stream' } val={ val }></packet-view-stream-value>
    <packet-view-custom-value if={ type=='custom' } tag={ tag } val={ val }></packet-view-custom-value>
  </p>
  <ul show={ opts.field.items.length && show }>
    <packet-view-item each={ f in opts.field.items } layer={ opts.layer } parentVal={ val } parent={ f } path={ path } field={ f }></packet-view-item>
  </ul>
</li>

<script>
  this.show = false;

  this.toggle = e => {
    if (opts.field.items.length) {
      this.show = !this.show;
    }
    e.stopPropagation();
  };

  this.rangeOut = () => this.parent.rangeOut();

  this.fieldRange = e => {
    this.parent.fieldRange(e);
  };

  this.context = e => {
    if (window.getSelection().toString().length > 0) {
      if (this.path && typeof this.val !== 'object') {
        e.filterText = `${this.path} == ${JSON.stringify(this.val)}`;
      }
      Menu.popup('packet-view:context-menu', this, remote.getCurrentWindow(), {event: e});
      e.stopPropagation();
    }
  };

  this.on('update', () => {
    this.layer = opts.layer;
    this.val = opts.field.value.data;
    this.type = null;
    this.tag = null;
    let valType = opts.field.value.type;

    let id = opts.field.id;
    if (id) {
      this.path = opts.path + '.' + id;
      if (id in opts.parent.attrs) {
        this.val = opts.parent.attrs[id].data;
        valType = opts.parent.attrs[id].type;
      } else if (opts.parentval && id in opts.parentval) {
        this.val = opts.parentval[id];
      }
    }

    if (valType !== '') {
      let tag = 'packet-view-' + valType.replace(/\//g, '-');
      try {
        riot.render(tag, {val: this.val});
        this.type = 'custom';
        this.tag = tag;
      } catch (e) {
        // console.warn(`tag ${tag} not registered`);
      }
    }

    if (this.type == null) {
      if (typeof this.val === 'boolean') {
        this.type = 'boolean';
      } else if (Number.isInteger(this.val)) {
        this.type = 'integer';
      } else if (Buffer.isBuffer(this.val)) {
        this.type = 'buffer';
      } else if (this.val && this.val.constructor.name === 'LargeBuffer') {
        this.type = 'buffer';
      } else {
        this.type = 'string';
      }
    }
  });
</script>

<style type="text/less" scoped>
  :scope {
    -webkit-user-select: auto;
  }
</style>

</packet-view-item>

<packet-view-layer>
<p class="layer-name list-item" oncontextmenu={ layerContext } onclick={ toggleLayer } onmouseover={ layerRange } onmouseout={ rangeOut }>
  <i class="fa fa-arrow-circle-right" show={ !visible }></i>
  <i class="fa fa-arrow-circle-down" show={ visible }></i>
  { layer.name }
  <i class="text-summary">{ layer.summary }</i>
</p>
<ul show={ visible }>
  <packet-view-item each={ f in layer.items } layer={ layer } parent={ layer } path={ layer.id } field={ f }></packet-view-item>
  <li if={ layer.error }>
    <a class="text-label">Error:</a>
    { layer.error }
  </li>
</ul>
<packet-view-layer each={ ns in rootKeys } layer={ rootLayers[ns] } range={ range }></packet-view-layer>

<script>
  import {Menu, PubSub} from 'dripcap';
  this.visible = true;

  this.on('update', () => {
    this.range = (opts.range != null) ? (opts.range + ' ' + opts.layer.range) : opts.layer.range;
    this.layer = opts.layer;
    this.rootKeys = [];
    if (this.layer.layers != null) {
      this.rootLayers = this.layer.layers;
      this.rootKeys = Object.keys(this.rootLayers);
    }
  });

  this.layerContext = e => {
    this.clickedLayerNamespace = e.item.ns;
    e.filterText = this.layer.id;
    Menu.popup('packet-view:layer-menu', this, remote.getCurrentWindow(), {event: e});
    e.stopPropagation();
  };

  this.rangeOut = e => {
    PubSub.pub('packet-view:range', []);
  }

  this.fieldRange = e => {
    let range = this.range.split(' ');
    range.pop();
    range = range.concat((e.currentTarget.getAttribute('range') || '').split(' '));
    PubSub.pub('packet-view:range', range);
  }

  this.layerRange = e => {
    let range = this.range.split(' ');
    range.pop();
    PubSub.pub('packet-view:range', range);
  }

  this.toggleLayer = e => {
    this.visible = !this.visible;
    e.stopPropagation();
  };
</script>

</packet-view-layer>

<packet-view>

<div if={ packet }>
  <ul>
    <li>
      <i class="fa fa-circle-o"></i>
      <a class="text-label">
        Timestamp:
      </a>
      <i>{ packet.timestamp }</i>
    </li>
    <li>
      <i class="fa fa-circle-o"></i>
      <a class="text-label">
        Captured Length:
      </a>
      <i>{ packet.payload.length }</i>
    </li>
    <li>
      <i class="fa fa-circle-o"></i>
      <a class="text-label">
        Actual Length:
      </a>
      <i>{ packet.length }</i>
    </li>
  <li if={ packet.caplen < packet.length }> <i class="fa fa-exclamation-circle text-warn"> This packet has been truncated.</i> </li> </ul> <packet-view-layer each={ ns in rootKeys } layer={ rootLayers[ns] }></packet-view-layer>
</div>

<script>
  import {remote} from 'electron';

  this.set = pkt => {
    this.packet = pkt;
    if (pkt != null) {
      this.rootLayers = this.packet.layers;
      this.rootKeys = Object.keys(this.rootLayers);
    }
  };
</script>

<style type="text/less" scoped>
  :scope {
    -webkit-user-select: auto;
    table {
      width: 100%;
      align-self: stretch;
      border-spacing: 0;
      padding: 10px;
      td {
        cursor: default;
      }
    }
    .text-label {
      cursor: default;
    }
    .layer-name {
      white-space: nowrap;
      cursor: default;
      margin-left: 10px;
    }
    .text-summary {
      padding: 0 10px;
    }
    ul {
      padding-left: 20px;
    }
    li {
      white-space: nowrap;
      list-style: none;
    }
    i {
      font-style: normal;
    }
    i.base {
      font-weight: bold;
    }
    .label {
      margin: 0;
    }
    .fa-circle-o {
      opacity: 0.1;
    }
  }
</style>

</packet-view>
