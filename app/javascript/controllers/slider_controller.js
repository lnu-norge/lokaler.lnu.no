import { Controller } from "@hotwired/stimulus"
import Splide from '@splidejs/splide';

// Connects to data-controller="slider"
export default class extends Controller {
  static targets = [ "slider" ]
  static values = {
    startAt: 0,
    cover: true,
    height: ""
  }

  connect() {
    console.log("height", this.heightValue)
    const slider = this.sliderTarget
    new Splide(slider, {
      heightRatio: this.coverValue ? 2/3 : false,
      cover: this.coverValue,
      type: 'loop',
      lazyLoad: 'nearby',
      height: this.heightValue,
      pagination: false,
      start: this.startAtValue,
      i18n: {
        prev: 'Forrige',
        next: 'Neste',
        first: 'Første',
        last: 'Siste',
        slideX: 'Gå til %s',
        pageX: 'Side %s'
      }
    }).mount()
    slider.querySelectorAll('button').forEach(button =>
      button.onclick = event => {
        event.preventDefault()
      }
    )
  }

  disconnect() {
    super.disconnect();
  }
}
