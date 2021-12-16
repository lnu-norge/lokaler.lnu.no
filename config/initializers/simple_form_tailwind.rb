# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config| # rubocop:disable Metrics/BlockLength Layout/LineLength
  # Default class for buttons
  config.button_class = "button"

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = ""

  # How the label text should be generated altogether with the required text.
  config.label_text = ->(label, required, _explicit_label) { "#{label} #{required}" }
  config.label_class = "label"

  # Define the way to render check boxes / radio buttons with labels.
  config.boolean_style = :inline

  # You can wrap each item in a collection of radio/check boxes with a tag
  config.item_wrapper_tag = :div

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  config.include_default_input_wrapper_class = false

  # CSS class to add for error notification helper.
  config.error_notification_class = "error_notification"

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # :to_sentence to list all errors for each field.
  config.error_method = :to_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = "error_field"
  config.input_field_valid_class = "valid_field"

  # vertical forms
  #
  # vertical default_wrapper
  config.wrappers :vertical_form, tag: "div", class: "vertical_form" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "label", error_class: "label--error"
    b.use :input, class: "text_field", error_class: "error_field", valid_class: "valid_field"
    b.use :full_error, wrap_with: { tag: "p", class: "error_text" }
    b.use :hint, wrap_with: { tag: "p", class: "meta_text" }
  end

  config.wrappers :dropdown, tag: "div", class: "dropdown" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "label", error_class: "label--error"
    b.use :input,
          class: "dropdown",
          error_class: "error_field",
          valid_class: "valid_field",
          data: {
            controller: "tom-select",
            "tom-select-variant-value": "dropdown"
          }
    b.use :full_error, wrap_with: { tag: "p", class: "error_text" }
    b.use :hint, wrap_with: { tag: "p", class: "meta_text" }
  end

  # vertical input for boolean (aka checkboxes)
  config.wrappers :vertical_boolean, tag: "div", class: "boolean_form", error_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper tag: "div", class: "checkbox-wrapper" do |ba|
      ba.use :input, class: "checkbox"
    end
    b.wrapper tag: "div", class: "ml-3 text-sm" do |bb|
      bb.use :label, class: "block", error_class: "block error_text"
      bb.use :hint, wrap_with: { tag: "p", class: "block meta_text" }
      bb.use :full_error, wrap_with: { tag: "p", class: "block meta_text error_text" }
    end
  end

  # vertical input for radio buttons and check boxes
  config.wrappers :vertical_collection,
                  item_wrapper_class: "collection_form",
                  item_label_class: "item_label", tag: "div", class: "item_label_wrapper" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: "legend", class: "legend",
                           error_class: "error_text" do |ba|
      ba.use :label_text
    end
    b.use :input,
          class: "checkbox", error_class: "error_text", valid_class: "valid_text"
    b.use :full_error, wrap_with: { tag: "p", class: "meta_text error_text" }
    b.use :hint, wrap_with: { tag: "p", class: "meta_text" }
  end

  # vertical file input
  config.wrappers :vertical_file, tag: "div", class: "vertical_form" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label
    b.use :input, class: "file_field", error_class: "error_text error_field"
    b.use :full_error, wrap_with: { tag: "p", class: "meta_text error_text" }
    b.use :hint, wrap_with: { tag: "p", class: "meta_text" }
  end

  # vertical multi select
  config.wrappers :vertical_multi_select, tag: "div", class: "", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: "legend", class: "legend",
                           error_class: "text-red-500" do |ba|
      ba.use :label_text
    end
    b.wrapper tag: "div", class: "multi_select_wrapper" do |ba|
      # ba.use :input, class: 'flex w-auto w-auto text-gray-500 text-sm border-gray-300 rounded p-2', error_class: 'text-red-500', valid_class: 'text-green-400' # rubocop:disable Layout/LineLength
      ba.use :input,
             class: "multi_select"
    end
    b.use :full_error, wrap_with: { tag: "p", class: "meta_text error_text" }
    b.use :hint, wrap_with: { tag: "p", class: "meta_text" }
  end

  # vertical range input
  config.wrappers :vertical_range, tag: "div", class: "", error_class: "error_text",
                                   valid_class: "text-green-400" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.optional :step
    b.use :label, class: "legend block", error_class: "error_text"
    b.wrapper tag: "div", class: "range_field_wrapper" do |ba|
      ba.use :input, class: "range_field",
                     error_class: "error_text", valid_class: "valid_text"
    end
    b.use :full_error, wrap_with: { tag: "p", class: "meta_text error_text" }
    b.use :hint, wrap_with: { tag: "p", class: "meta_text" }
  end

  config.wrappers :rich_text, tag: "div", class: "rich_text" do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: "label", error_class: "label--error"
    b.use :input, class: "text_field", error_class: "error_field", valid_class: "valid_field",
                  data: { controller: "trix-paste" }
    b.use :full_error, wrap_with: { tag: "p", class: "error_text" }
    b.use :hint, wrap_with: { tag: "p", class: "meta_text" }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :vertical_form

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper that will be used for all inputs with specified type.
  config.wrapper_mappings = {
    boolean: :vertical_boolean,
    check_boxes: :vertical_collection,
    date: :vertical_multi_select,
    datetime: :vertical_multi_select,
    file: :vertical_file,
    radio_buttons: :vertical_collection,
    range: :vertical_range,
    time: :vertical_multi_select,
    rich_text_area: :rich_text
  }
end
