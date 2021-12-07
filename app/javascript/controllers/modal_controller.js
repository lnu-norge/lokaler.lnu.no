import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = [ "modal", "background", "closeButton" ]

  connect() {
    this.backgroundTarget.onclick = (event) => {
      // Check that we didn't click anything else:
      if (event.target !== this.backgroundTarget) return

      // Then close the modal:
      this.closeButtonTarget.click()
    }
  }
  disconnect() {
    super.disconnect();
  }
}
