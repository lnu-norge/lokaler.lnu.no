# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV["SENDGRID_FROM_EMAIL"] || "lokaler@lnu.no"
  layout "mailer"
end
