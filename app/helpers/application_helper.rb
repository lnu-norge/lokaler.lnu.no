# frozen_string_literal: true

module ApplicationHelper
  def helper_flash_type(msg_type, message)
    case msg_type
    when 'successs'
      render partial: 'shared/success', locals: { message: message }
    when 'alert'
      render partial: 'shared/alert', locals: { message: message }
    end
  end
end
