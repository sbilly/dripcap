import $ from 'jquery';
import _ from 'underscore';
import riot from 'riot';
import fs from 'fs';
import Component from 'dripcap-core/component';
import {
  remote
} from 'electron';
const {
  Menu,
  MenuItem,
  dialog
} = remote;
import {
  Session,
  Package,
  PubSub,
  KeyBind
} from 'dripcap-core';

export default class PacketListView {
  async activate() {
    this.comp = await Component.create(`${__dirname}/../tag/*.tag`);
    let pkg = await Package.load('main-view');

    let m = $('<div class="wrapper noscroll" />');
    pkg.root.panel.left('packet-list-view', m);

    let n = $('<div class="wrapper" />').attr('tabIndex', '0').appendTo(m);
    this.list = riot.mount(n[0], 'packet-list-view', {
      items: []
    })[0];

    this.view = $('[riot-tag=packet-list-view]');
    this.view.scroll(_.throttle((() => this.update()), 200));

    let refresh = _.debounce(() => {
      PubSub.pub('core:session-packet', this.session.get(this.selectedId));
    }, 200);

    let cellHeight = 32;

    KeyBind.bind('up', '[riot-tag=packet-list-view]', () => {
      let cell = this.main.children(`div.packet[data-packet=${this.selectedId}]:visible`);
      let nextIndex = 0;

      if (this.filtered < 0) {
        if (this.packets > 0) {
          if (this.selectedId > 1) {
            this.selectedId--;
          } else {
            this.selectedId = 1;
          }
          nextIndex = this.selectedId;
        } else {
          return;
        }
      } else {
        if (this.filtered > 0) {
          nextIndex = parseInt(cell.css('top')) / cellHeight - 1;
          let list = this.session.getFiltered('main', nextIndex, nextIndex);
          if (list[0]) {
            this.selectedId = list[0];
          } else {
            return;
          }
        } else {
          return;
        }
      }

      this.cells.removeClass('selected');
      let pos = nextIndex * cellHeight;
      let top = this.view.scrollTop();
      let diff = pos - (cellHeight * 2) - top;
      if (diff < 0) {
        this.view.scrollTop(this.view.scrollTop() + diff);
      } else if (pos > this.view.scrollTop() + this.view.height()) {
        this.view.scrollTop(pos - this.view.height() + cellHeight * 2);
      }
      this.main.children(`div.packet[data-packet=${this.selectedId}]`).addClass('selected');
      refresh();

      return false;
    });

    KeyBind.bind('down', '[riot-tag=packet-list-view]', () => {
      let cell = this.main.children(`div.packet[data-packet=${this.selectedId}]:visible`);
      let nextIndex = 0;

      if (this.filtered < 0) {
        if (this.packets > 0) {
          if (this.selectedId < 1) {
            this.selectedId = 1;
          } else if (this.selectedId < this.packets) {
            this.selectedId++;
          }
          nextIndex = this.selectedId;
        } else {
          return;
        }
      } else {
        if (this.filtered > 0) {
          nextIndex = parseInt(cell.css('top')) / cellHeight + 1;
          let list = this.session.getFiltered('main', nextIndex, nextIndex);
          if (list[0]) {
            this.selectedId = list[0];
          } else {
            return;
          }
        } else {
          return;
        }
      }

      this.cells.removeClass('selected');
      let pos = nextIndex * cellHeight;
      let bottom = this.view.scrollTop() + this.view.height();
      let diff = pos + (cellHeight * 2) - bottom;
      if (diff > 0) {
        this.view.scrollTop(this.view.scrollTop() + diff);
      } else if (pos < this.view.scrollTop()) {
        this.view.scrollTop(pos - cellHeight * 2);
      }
      this.main.children(`div.packet[data-packet=${this.selectedId}]`).addClass('selected');
      refresh();

      return false;
    });

    PubSub.sub('core:session-packet', pkt => {
      if (pkt.seq === this.selectedId) {
        PubSub.pub('packet-list-view:select', pkt);
      }
      process.nextTick(() => {
        this.cells.filter(`[data-packet=${pkt.seq}]:visible`)
          .empty()
          .append($('<a>').text(pkt.name))
          .append($('<a>').text(pkt.attrs.src.data))
          .append($('<a>').append($('<i class="fa fa-angle-double-right">')))
          .append($('<a>').text(pkt.attrs.dst.data))
          .append($('<a>').text(pkt.length));
      });
    });

    this.main = $('[riot-tag=packet-list-view] div.main');

    let canvas = $("<canvas width='64' height='64'>")[0];
    let ctx = canvas.getContext("2d");
    ctx.fillStyle = 'rgba(255, 255, 255, 0.05)';
    ctx.fillRect(0, 0, 64, 32);
    this.main.css('background-image', `url(${canvas.toDataURL('image/png')})`);

    PubSub.sub('packet-filter-view:filter', filter => {
      this.filtered = 0;
      this.reset();
      this.update();
    });

    PubSub.sub('core:session-created', session => {
      this.session = session;
      this.packets = 0;
      this.filtered = -1;
      this.selectedId = -1;
      this.reset();
      this.update();
      process.nextTick(() => { $('[riot-tag=packet-list-view]').focus() });
    });

    PubSub.sub('core:capturing-status', n => {
      if (n.packets < this.packets) {
        this.reset();
      }
      this.packets = n.packets;
      if (n.filtered.main != null) {
        this.filtered = n.filtered.main;
      } else {
        this.filtered = -1;
      }
      this.update();
    });

    this.reset();
  }

  reset() {
    this.prevStart = -1;
    this.prevEnd = -1;
    this.main.empty();
    this.cells = $([]);
  }

  update() {
    let margin = 5;
    let height = 32;

    let num = this.packets;
    if (this.filtered !== -1) {
      num = this.filtered;
    }

    if (num > 0 && this.view.height() === 0) {
      setTimeout(() => {
        this.update();
      }, 500);
    }

    this.main.css('height', (height * num) + 'px');
    let start = Math.max(1, Math.floor((this.view.scrollTop() / height) - margin));
    let end = Math.min(num, Math.floor(((this.view.scrollTop() + this.view.height()) / height) + margin));

    this.cells.filter(':visible').each((i, ele) => {
      let pos = parseInt($(ele).css('top'));
      if (pos + $(ele).height() + (margin * height) < this.view.scrollTop() || pos - (margin * height) > this.view.scrollTop() + this.view.height()) {
        $(ele).hide();
      }
    });

    if (this.prevStart !== start || this.prevEnd !== end) {
      this.prevStart = start;
      this.prevEnd = end;
      if ((this.session != null) && start <= end) {
        if (this.filtered === -1) {
          let list = [];
          for (let i = start; i <= end; ++i) {
            list.push(i);
          }
          this.updateCells(start - 1, list);
        } else {
          let list = this.session.getFiltered('main', start - 1, end - 1);
          this.updateCells(start - 1, list);
        }
      }
    }
  }

  updateCells(start, list) {
    let packets = [];
    let indices = [];
    for (let n = 0; n < list.length; n++) {
      let id = list[n];
      if (!this.cells.is(`[data-packet=${id}]:visible`)) {
        packets.push(id);
        indices.push(start + n);
      }
    }

    let needed = packets.length - this.cells.filter(':not(:visible)').length;
    if (needed > 0) {
      for (let i = 1; i <= needed; ++i) {
        let self = this;
        $('<div class="packet list-item">').appendTo(this.main).hide().click(function() {
          $(this).siblings('.selected').removeClass('selected');
          $(this).addClass('selected');
          self.selectedId = parseInt($(this).attr('data-packet'));
          process.nextTick(() => {
            PubSub.pub('core:session-packet', self.session.get(self.selectedId));
          });
        });
      }

      this.cells = this.main.children('div.packet');
    }

    this.cells.filter(':not(:visible)').each((i, ele) => {
      if (i >= packets.length) {
        return;
      }
      let id = packets[i];
      $(ele).attr('data-packet', id).toggleClass('selected', this.selectedId === id).empty().css('top', (32 * indices[i]) + 'px').show();
    });

    for (let pkt of packets) {
      PubSub.pub('core:session-packet', this.session.get(pkt));
    }
  }

  async deactivate() {
    let pkg = await Package.load('main-view');
    pkg.root.panel.left('packet-list-view');
    this.list.unmount();
    this.comp.destroy();
  }
}
