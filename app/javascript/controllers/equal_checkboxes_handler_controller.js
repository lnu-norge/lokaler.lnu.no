import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="equal-checkboxes-handler"
export default class extends Controller {
  // Handles the case where a form has multiple check boxes with the same id,
  // by making sure they are all checked

  static targets = ['form']

  connect() {
    this.handleDuplicateCheckboxesAndRadios()
    this.handleDuplicateTextInputs()
  }

  handleDuplicateTextInputs() {
    // First we get all input fields (no support for textareas yet)
    const input_fields = [
      ...this.formTarget.querySelectorAll('input[type=text]')
    ]

    // Then we get duplicates, grouped by id:
    const grouped_duplicates = this.group_duplicates(input_fields)

    grouped_duplicates.forEach((group) => {
      group.forEach((field, index) => {
        // Equalize all checked values:
        // TODO: HANDLE FOR INPUTS
      })
    })

  }

  handleDuplicateCheckboxesAndRadios() {
    // First we get all checkboxes and radio buttons (no support for input fields yet)
    const input_fields = [
      ...this.formTarget.querySelectorAll('input[type=checkbox]'),
      ...this.formTarget.querySelectorAll('input[type=radio]'),
    ]

    // Then we get duplicates, grouped by id:
    const grouped_duplicates = this.group_duplicates(input_fields)

    // Then we handle everything:
    grouped_duplicates.forEach((group) => {
      group.forEach((field, index) => {
        // Equalize all checked values:
        field.checked = group[group.length - 1].checked

        // Set a click handler:
        field.onclick = () => {
          group.forEach(duplicate => duplicate.checked = field.checked)
        }

        // Only do the rest for the duplicates:
        if (index === 0) return

        // Add unique ids:
        field.dataset.original_id = field.id
        field.id = `${field.id}-${index}`

        // Update labels with correct for
        const label = field.parentElement.querySelector(`label[for=${field.dataset.original_id}]`)
        label.setAttribute('for', field.id)

        // Set a fake namm:
        field.setAttribute('name', `duplicate_${index}_of_${field.name}`)

        // Then check again, as it's lost when name is set:
        field.checked = group[0].checked
      })
    })
  }

  group_duplicates(input_fields) {
    // Pretty sure this could be handled with a .reduce or something...
    const id_count = {}
    input_fields.forEach(input => {
      id_count[input.id] = id_count[input.id] ? 1 + id_count[input.id] : 1
    })

    const duplicate_input_fields = input_fields.filter(input => id_count[input.id] > 1 )

    const grouped_duplicates = duplicate_input_fields.reduce((group, field) => {
      group[field.id] = group[field.id] ?  [...group[field.id], field] : [field]
      return group
    }, {})

    return Object.values(grouped_duplicates)
    // [ [field, field], [field, field] ... ]
  }
}
