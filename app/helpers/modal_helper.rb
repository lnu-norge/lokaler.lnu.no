# frozen_string_literal: true

module ModalHelper
  def modal_link_to(text, path, **options)
    id = options[:id] || path
    turbo_frame_tag id do
      link_to text, path, **options
    end
  end

  def modal_link_to_with_block(path, **options, &block)
    id = options[:id] || path
    turbo_frame_tag id do
      link_to path, **options do
        yield block
      end
    end
  end

  def modal_content_for(id, parent, &block)
    render partial: "shared/modal", locals: {
      id: id,
      parent: parent,
      block: block
    }
  end
end
