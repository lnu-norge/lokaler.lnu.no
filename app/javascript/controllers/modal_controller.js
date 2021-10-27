import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = [ "modal", "background" ]

  connect() {
    console.log('Modal connected')
    this.modalTarget.onclick = () => {
      alert("hi")
    }
    this.backgroundTarget.onclick = (event) => {
      // Check that we didn't click anything above it:
      if (event.target !== this.backgroundTarget) {
        return console.log(event)
      }
      alert ("clicked background")
    }
  }
}
