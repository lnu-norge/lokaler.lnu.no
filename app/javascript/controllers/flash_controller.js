import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['flash']

  connect() {
    setTimeout(() => {
      this.element.classList.remove('opacity-0');
      this.element.classList.add('opacity-100');

      setTimeout(() => {
        this.disconnect();
      }, 3500);
    }, 10);
  }

  disconnect() {
    this.element.classList.remove('opacity-100');
    this.element.classList.add('opacity-0');

    setTimeout(() => {
      this.flashTarget.remove();
    }, 1000);
  }
}
