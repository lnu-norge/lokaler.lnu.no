# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def helper_flash_type(msg_type, message)
    case msg_type
    when "notice"
      render partial: "shared/notice", locals: { message: }
    when "alert"
      render partial: "shared/alert", locals: { message: }
    end
  end

  def active_path?(path)
    return current_page?(root_path) if path == "/lokaler" && current_page?(root_path)

    current_page?(path) || request.path.start_with?(path)
  end
end
