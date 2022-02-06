# frozen_string_literal: true

module ModalHelper
  def turbo_modal_link_to(text, path, **options)
    id = options[:id] || path
    turbo_frame_tag id do
      link_to text, path, **options
    end
  end

  def turbo_modal_link_to_with_block(path, **options, &block)
    id = options[:id] || path
    turbo_frame_tag id do
      link_to path, **options do
        yield block
      end
    end
  end

  def turbo_modal_content_for(id, parent, &block)
    render partial: "shared/turbo_modal", locals: {
      id: id,
      parent: parent,
      block: block
    }
  end

  def button_to_modal(modal_id, **options, &block)
    button_tag **options, data: {
      controller: "modal",
      "modal-target": "openButton",
      "modal-to-toggle": modal_id
    } do
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
