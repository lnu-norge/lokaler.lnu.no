# frozen_string_literal: true

module ApplicationHelper
  def helper_flash_type(msg_type, message)
    case msg_type
    when "notice"
      render partial: "shared/notice", locals: { message: message }
    when "alert"
      render partial: "shared/alert", locals: { message: message }
    end
  end

  def modal_link_to(text, id, **options)
    turbo_frame_tag id do
      link_to text, id, **options
    end
  end

  def modal_content_for(id, parent, &block)
    render partial: 'shared/modal', locals: {
      id: id,
      parent: parent,
      block: block
    }
  end
end
