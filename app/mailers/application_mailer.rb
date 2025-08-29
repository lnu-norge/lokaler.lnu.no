# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV["FROM_EMAIL"] || "Lokaler LNU <robot@lokaler.lnu.no>",
          reply_to: "lokaler@lnu.no"
  layout "mailer"
end
