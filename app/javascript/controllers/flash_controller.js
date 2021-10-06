import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.remove('opacity-0');
      this.element.classList.add('opacity-100');

      setTimeout(() => {
        this.disconnect()
      }, 3500)
    }, 50)
  }

  disconnect() {
    setTimeout(() => {
      this.element.classList.remove('opacity-100');
      this.element.classList.add('opacity-0');
    }, 50)
  }
}
