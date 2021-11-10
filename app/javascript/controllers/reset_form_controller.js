import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reset_form"
export default class extends Controller {
  static targets = ['title']

  reset() {
    this.element.reset();
    this.titleTarget.focus();
  }
}
