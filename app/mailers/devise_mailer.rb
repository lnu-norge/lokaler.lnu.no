# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  include Rails.application.routes.url_helpers

  def reset_password_instructions(record, token, _opts)
    SendgridMailer.send(record.email,
                        ENV["SENDGRID_RESET_TEMPLATE_ID"],
                        user_id: record.id,
                        url: Rails.application.routes.url_helpers.edit_user_password_url(@resource, reset_password_token: token)) # rubocop:disable Layout/LineLength
  end
end
