import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden"
export default class extends Controller {
  static targets = ["hideToggle", "title"]

  toggle() {
    this.hideToggleTarget.classList.toggle("hidden");
    this.titleTarget.focus();
  }
}
