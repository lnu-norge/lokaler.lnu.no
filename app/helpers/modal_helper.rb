# frozen_string_literal: true

module ModalHelper
  def button_to_modal(modal_id, **options, &block)
    aria_options = {
      "aria-haspopup": "dialog",
      "aria-expanded": "false"
    }

    button_tag(
      type: "button",
      **options,
      **aria_options,
      data: {
        controller: "modal",
        action: "modal#open",
        "modal-id-param": modal_id
      }
    ) do
      yield block
    end
  end

  def modal_for(modal_id, modal_classes = "", &block)
    content_tag :template, data: { "modal-id": modal_id, "modal-target": "template" } do
      render partial: "shared/modal", locals: {
        modal_id:,
        modal_classes:,
        block:
      }
    end
  end
end
