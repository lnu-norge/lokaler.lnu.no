import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
    static values = {
        options: {},
        variant: String,
        itemName: String
    }

    connect() {
        const options = createOptions(this.optionsValue, this.variantValue, this.itemNameValue)

        this.tomselect = new TomSelect(
            this.element,
            options
        );
    }
}

const createOptions = (options, variant = null, itemName = null) => {
    const default_options = {
        render:{
            option_create: ( data, escape ) => {
                return `<div class="create">Lag ny${ itemName ? ' ' + itemName : ''}: <strong>${escape(data.input)}</strong>&hellip;</div>`;
            },
            no_results: () => {
                return '<div class="no-results">Ingen match</div>';
            },
        }
    }

    const variant_options = {
        "dropdown": {
            plugins: ['dropdown_input']
        }
    }

    if (variant && !variant_options[variant]) {
        throw "Invalid variant. Not in list of variant options"
    }

    return {
        ...default_options,
        ...(variant ? variant_options[variant] : {}),
        ...options
    }
}
