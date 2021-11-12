import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static values = {
    allowNew: Boolean,
  }
  connect() {
    this.tomselect = new TomSelect(
      this.element,
      {
        create: this.allowNewValue,
      }
    );
  }
}
