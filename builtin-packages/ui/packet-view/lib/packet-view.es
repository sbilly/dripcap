import { remote, clipboard } from 'electron';
let { MenuItem } = remote;
let { dialog } = remote;
import fs from 'fs';
import notifier from 'node-notifier';
import { Menu, Package, PubSub, Session, Layout } from 'dripcap';

export default class PacketView {
  async activate() {
    Layout.require(__dirname + '/../tag/packet-view.tag');
    let layout = {
      center: {
        tag: 'packet-view'
      },
      name: 'Packet',
      id: 'packet-view'
    };
    Layout.container('drip-tab-top').append(layout);

    this.copyMenu = function(menu, e) {
      if (window.getSelection().toString().length > 0) {
        let copy = () => remote.getCurrentWebContents().copy();
        menu.append(new MenuItem({
          label: 'Copy',
          click: copy,
          accelerator: 'CmdOrCtrl+C'
        }));
      }
      return menu;
    };

    this.filterMenu = function(menu, e) {
      if (e.filterText) {
        menu.append(new MenuItem({
          label: 'Filter: ' + e.filterText,
          click: () => {
            PubSub.pub('packet-filter-view:set-filter', e.filterText);
          }
        }));
      }
      return menu;
    };

    this.numValueMenu = function(menu, e) {
      let setBase = base => {
        return () => this.base = base;
      };

      menu.append(new MenuItem({
        label: 'Binary',
        type: 'radio',
        checked: (this.base === 2),
        click: setBase(2)
      }));
      menu.append(new MenuItem({
        label: 'Octal',
        type: 'radio',
        checked: (this.base === 8),
        click: setBase(8)
      }));
      menu.append(new MenuItem({
        label: 'Decimal',
        type: 'radio',
        checked: (this.base === 10),
        click: setBase(10)
      }));
      menu.append(new MenuItem({
        label: 'Hexadecimal',
        type: 'radio',
        checked: (this.base === 16),
        click: setBase(16)
      }));
      return menu;
    };

    this.layerMenu = function(menu, e) {
      let find = function(layer, ns) {
        if (layer.layers != null) {
          for (var k in layer.layers) {
            var v = layer.layers[k];
            if (k === ns) {
              return v;
            }
          }
          for (k in layer.layers) {
            var v = layer.layers[k];
            let r = find(v, ns);
            if (r != null) {
              return r;
            }
          }
        }
      };

      let exportRawData = () => {
        let layer = find(this.packet, this.clickedLayerNamespace);
        let filename = `${this.packet.interface}-${layer.name}-${this.packet.timestamp.toISOString()}.bin`;
        let path = dialog.showSaveDialog(remote.getCurrentWindow(), {
          defaultPath: filename
        });
        if (path != null) {
          fs.writeFileSync(path, layer.payload.apply(this.packet.payload));
        }
      };

      let exportPayload = () => {
        let layer = find(this.packet, this.clickedLayerNamespace);
        let filename = `${this.packet.interface}-${layer.name}-${this.packet.timestamp.toISOString()}.bin`;
        let path = dialog.showSaveDialog(remote.getCurrentWindow(), {
          defaultPath: filename
        });
        if (path != null) {
          fs.writeFileSync(path, layer.payload.apply(this.packet.payload));
        }
      };

      let copyAsJSON = () => {
        let layer = find(this.packet, this.clickedLayerNamespace);
        let json = JSON.stringify(layer, null, ' ');
        clipboard.writeText(json);
        return notifier.notify({
          title: 'Copied',
          message: json
        });
      };

      menu.append(new MenuItem({
        label: 'Export raw data',
        click: exportRawData
      }));
      menu.append(new MenuItem({
        label: 'Export payload',
        click: exportPayload
      }));
      menu.append(new MenuItem({
        type: 'separator'
      }));
      menu.append(new MenuItem({
        label: 'Copy Layer as JSON',
        click: copyAsJSON
      }));
      return menu;
    };

    Menu.register('packet-view:layer-menu', this.layerMenu);
    Menu.register('packet-view:layer-menu', this.filterMenu);
    Menu.register('packet-view:layer-menu', this.copyMenu);
    Menu.register('packet-view:numeric-value-menu', this.numValueMenu);
    Menu.register('packet-view:numeric-value-menu', this.copyMenu);
    Menu.register('packet-view:context-menu', this.filterMenu);
    Menu.register('packet-view:context-menu', this.copyMenu);
  }

  async deactivate() {
    Menu.unregister('packet-view:layer-menu', this.layerMenu);
    Menu.unregister('packet-view:layer-menu', this.filterMenu);
    Menu.unregister('packet-view:layer-menu', this.copyMenu);
    Menu.unregister('packet-view:numeric-value-menu', this.numValueMenu);
    Menu.unregister('packet-view:numeric-value-menu', this.copyMenu);
    Menu.unregister('packet-view:context-menu', this.filterMenu);
    Menu.unregister('packet-view:context-menu', this.copyMenu);
    
    Layout.container('drip-tab-top').remove('packet-view');
    Layout.unregister('packet-view');
    PubSub.removeHolder(this);
  }
}
