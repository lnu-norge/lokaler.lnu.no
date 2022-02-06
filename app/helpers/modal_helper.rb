# frozen_string_literal: true

module ModalHelper
  def button_to_modal(modal_id, **options, &block)
    button_tag(**options, data: {
                 controller: "modal",
                 "modal-target": "openButton",
                 "modal-to-toggle": modal_id
               }) do
      yield block
    end
  end

  def button_close_modal(modal_id, **options, &block)
    button_tag(**options, data: {
                 controller: "modal",
                 "modal-target": "closeButton",
                 "modal-to-toggle": modal_id
               }) do
      yield block
    end
  end

  def modal_for(modal_id, &block)
    render partial: "shared/modal", locals: {
      modal_id: modal_id,
      block: block
    }
  end
end
