import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden"
export default class extends Controller {
  static targets = ["hideToggle", "title", "open", "close"]

  toggle() {
    this.openTarget.classList.toggle("hidden");
    this.closeTarget.classList.toggle("hidden");
    this.hideToggleTarget.classList.toggle("hidden");
    this.titleTarget.focus();
  }
}
