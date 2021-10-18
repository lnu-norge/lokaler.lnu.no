import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static values = {
    options: Object
  };

  connect() {
    this.accessToken = this.element.dataset.apiKey;
    this.tomselect = new TomSelect('#locationInput', {
      valueField: 'text',
      labelField: 'text',
      searchField: 'text',
      load: (search, callback) => {
        this.searchMapbox(search, callback)
      }}
    );
  }

  async searchMapbox(search, callback) {
    if(search == "")
      callback([]);

    const url =`https://api.mapbox.com/geocoding/v5/mapbox.places/${search}.json?access_token=${this.accessToken}`;

    const data = [];

    const features = await (await fetch(url)).json();

    features.features.forEach((feature) => {
      data.push({text: feature.text});
    });

    callback(data);
  }
}
