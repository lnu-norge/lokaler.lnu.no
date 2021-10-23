import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static values = {
    options: Object
  };

  connect() {
    this.tomselect = new TomSelect('#locationInput', {
      valueField: 'text',
      labelField: 'text',
      searchField: 'text',
      allowEmptyOption: true,
      create: true,
      load: (search, callback) => {
        this.searchMapbox(search, callback)
      }}
    );
  }

  async searchMapbox(search, callback) {
    if(search === "")
      callback([]);

    const url =`https://ws.geonorge.no/stedsnavn/v1/sted?sok=${search}&fuzzy=true`

    const result = await (await fetch(url)).json();

    const data = result.navn.map((name) => {
      return { text: name.stedsnavn[0].skrivemåte }
    });

    callback(data);
  }
}
