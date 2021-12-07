import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden"
export default class extends Controller {
  static targets = ["toggleableElement", "focus"]

  toggle() {
    this.toggleableElementTarget.classList.toggle("hidden");
    const hidden = this.toggleableElementTarget.classList.contains("hidden");
    if (!hidden) {
      this.focusTarget.focus();
    }
  }
}
