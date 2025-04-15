import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  click(event) {
    // Don't navigate when clicking a link or button within the row
    if (event.target.closest('a, button') || event.target.tagName.toLowerCase() === 'a' || event.target.tagName.toLowerCase() === 'button') {
      return
    }

    window.location.href = this.urlValue
  }
}