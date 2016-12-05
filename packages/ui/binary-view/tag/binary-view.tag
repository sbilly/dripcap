<binary-view>
  <div class="container">
    <div class="hex"></div>
    <div class="ascii"></div>
  </div>

  <a onclick={ load } if={ pkt && pkt.len - pkt.payload.length > visibleLength && pkt.stream } href="#">
    { pkt.len - pkt.payload.length - visibleLength } bytes are omitted.<br>
    Click here to show more { Math.min(1024, pkt.len - pkt.payload.length - visibleLength) } bytes.
  </a>

  <script>
    const $ = require('jquery');
    const { PubSub } = require('dripcap');

    this.hexhtml = '';
    this.asciihtml = '';
    this.visibleLength = 0;
    this.pkt = null;

    this.on('mount', () => {
      this.ulhex = $(this.root).find('.hex');
      this.ulascii = $(this.root).find('.ascii');

      PubSub.sub(this, 'packet-list-view:select', (pkt) => {
        this.set(pkt);
        this.update();
      });

      PubSub.sub(this, 'packet-view:range', (array) => {
        this.ulhex.find('i').removeClass('selected');
        this.ulascii.find('i').removeClass('selected');
        if (array.length > 0) {
          let range = [0, this.ulascii.find('i').length];
          for (let r of array) {
            if (r !== '') {
              let n = r.split(':');
              n[0] = (n[0] === '') ? 0 : parseInt(n[0]);
              n[1] = (n[1] === '') ? range[1] : parseInt(n[1]);
              range[0] = Math.min(range[0] + n[0], range[1]);
              range[1] = Math.min(range[0] + (n[1] - n[0]), range[1]);
            }
          }
          this.ulhex.find('i').slice(range[0], range[1]).addClass('selected');
          this.ulascii.find('i').slice(range[0], range[1]).addClass('selected');
        }
      });
    });

    this.on('unmount', () => {
      PubSub.removeHolder(this);
    });

    set(pkt) {
      this.reset();
      this.pkt = pkt;
      this.append(pkt.payload);
    };

    reset() {
      this.pkt = null;
      this.hexhtml = '';
      this.asciihtml = '';
      this.visibleLength = 0;
      this.ulhex[0].innerHTML = this.hexhtml;
      this.ulascii[0].innerHTML = this.asciihtml;
    }

    load() {
      if (this.pkt.stream) {
        this.pkt.stream.read(1024).then((payload) => {
          this.visibleLength += payload.length;
          this.append(payload);
          this.update();
        });
      }
    }

    append(payload) {
      for (let i = 0; i < payload.length; i++) {
        var b = payload[i];
        let hex = ('0' + b.toString(16)).slice(-2);
        this.hexhtml += `<i class="list-item">${hex}</i>`;
      }

      for (let j = 0; j < payload.length; j++) {
        var b = payload[j];
        let text =
          0x21 <= b && b <= 0x7e ?
          String.fromCharCode(b) :
          '.';
        this.asciihtml += `<i class="list-item">${text}</i>`;
      }

      this.ulhex[0].innerHTML = this.hexhtml;
      this.ulascii[0].innerHTML = this.asciihtml;
    };
  </script>

  <style type="text/less">
    :scope {
      .container {
        display: flex;
        justify-content: center;
        width: 100%;
      }

      .ascii,
      .hex {
        list-style: none;
        font-family: monospace;
        padding: 10px;
        -webkit-user-select: text;
      }

      a {
        display: block;
        padding: 10px;
        text-align: center;
      }

      i {
        display: inline-block;
        font-style: normal;
        width: 23px;
        &.selected {
          color: var(--color-default-background);
          background-color: var(--color-variables);
        }
      }
    }

  </style>

</binary-view>
