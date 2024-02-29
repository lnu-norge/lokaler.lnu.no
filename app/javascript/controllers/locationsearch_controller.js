import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'
import fylkerAndKommuner from "./search_and_filter/fylker_and_kommuner";

export default class extends Controller {
  static values = {
    options: Object
  };

  connect() {
    this.tomselect = new TomSelect('#locationInput', {
          maxOptions: null,
          valueField: 'value',
          labelField: 'kommune',
          searchField: ['kommune', 'fylke'],
          optgroupField: 'fylke',
          sortField: ['fylke', 'kommune'],
          persist: false, // but do not store user inputted options as dropdown items
          plugins: ['clear_button'], // For multiple select
          optgroups: this.optGroups,
          options: this.options
        }
    );
  }

  get optGroups() {
    return fylkerAndKommuner.map(fylke => ({ value: fylke.name, label: fylke.name }))
  }

  get options() {
    return fylkerAndKommuner.map(fylke => {
      const options = []

      options.push({
        kommune: `Hele ${fylke.name}`,
        value: fylke.id,
        fylke: fylke.name
      })

      if (fylke.kommuner) {
        fylke.kommuner.forEach(kommune => {
          options.push({
            kommune: kommune.name,
            value: kommune.id,
            fylke: fylke.name
          })
        })
      }

      return options
    }).flat()
  }
}

