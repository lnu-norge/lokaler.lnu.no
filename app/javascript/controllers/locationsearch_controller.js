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
          valueField: 'kommune',
          labelField: 'kommune',
          searchField: ['kommune', 'fylke'],
          optgroupField: 'fylke',
          sortField: ['fylke', 'kommune'],
          allowEmptyOption: true,
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
    console.log(fylkerAndKommuner)
    return fylkerAndKommuner.map(fylke => {
      if (!fylke.kommuner) return {
        kommune: fylke.name,
        fylke: fylke.name
      }

      return fylke.kommuner.map(kommune => {
        return {
          kommune: kommune.name,
          fylke: fylke.name
        }
      })
    }).flat()
  }
}

