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

  def modal_for(modal_id, &block)
    render partial: "shared/modal", locals: {
      modal_id: modal_id,
      block: block
    }
  end

  def modal_button_for(text = nil, modal_id = nil, **options)
    button_tag text, {
      data: {
        controller: "modal",
        action: "click->modal#openModal",
        modal_id: modal_id
      },
      **options
    }
  end
end
