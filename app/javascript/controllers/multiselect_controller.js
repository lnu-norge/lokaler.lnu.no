import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  connect() {
    this.tomselect = new TomSelect(this.element);
  }
}
