# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  include Rails.application.routes.url_helpers

  def reset_password_instructions(record, token, _opts)
    SendgridMailer.send(record.email,
                        ENV['SENDGRID_RESET_TEMPLATE_ID'],
                        user_id: record.id,
                        token: token)
  end
end
