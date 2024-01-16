# frozen_string_literal: true

module ApplicationHelper
  def helper_flash_type(msg_type, message)
    case msg_type
    when "notice"
      render partial: "shared/notice", locals: { message: }
    when "alert"
      render partial: "shared/alert", locals: { message: }
    end
  end
end
