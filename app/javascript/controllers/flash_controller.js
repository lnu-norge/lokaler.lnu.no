import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['flash']
  static values = {
    type: String
  }

  connect() {
    setTimeout(() => {
      this.element.classList.remove('opacity-0');
      this.element.classList.add('opacity-100');

      // Only auto-dismiss notices, keep alerts and other types visible until dismissed
      if (this.typeValue === "notice") {
        setTimeout(() => {
          this.disconnect();
        }, 3500);
      }
    }, 10);
  }

  disconnect() {
    this.element.classList.remove('opacity-100');
    this.element.classList.add('opacity-0');

    setTimeout(() => {
      this.flashTarget.classList.add('sr-only');
    }, 1000);
  }
}
