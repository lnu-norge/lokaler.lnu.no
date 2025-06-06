# frozen_string_literal: true

module Users
  class MagicLinksController < Devise::MagicLinksController
    include LoginAttemptLogger

    def show
      result = super

      # Get identifier from url
      identifier = request.query_string

      if user_signed_in?
        log_successful_login_by(identifier, login_method: "magic_link")
      else
        # Extract email from token if possible for failed login logging
        log_failed_login_by(identifier || "unknown", reason: "Invalid or expired magic link token",
                                                     login_method: "magic_link")
      end

      result
    end
  end
end
