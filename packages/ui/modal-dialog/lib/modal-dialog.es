import Component from 'dripcap-core/component';

export default class ModalDialog {
  async activate() {
    this.comp = await Component.create(`${__dirname}/../tag/*.tag`);
  }

  async deactivate() {
    this.comp.destroy();
  }
}
