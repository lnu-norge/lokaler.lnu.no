# frozen_string_literal: true

module LoginAttemptLogger
  extend ActiveSupport::Concern

  included do
    after_action :log_successful_login, if: -> { signed_in? && login_occurred? }
  end

  private

  def log_successful_login
    return unless current_user&.email

    LoginAttempt.create!(
      user: current_user,
      email: current_user.email,
      status: "successful",
      login_method: determine_login_method
    )

    # Clear the flag so we don't log again on subsequent requests
    session[:user_just_signed_in] = false
  end

  def log_failed_login(email, reason, method = "magic_link")
    # Skip logging if email is invalid
    return unless email.present? && email != "unknown"
    return unless email.match?(URI::MailTo::EMAIL_REGEXP)

    LoginAttempt.create!(
      user: User.find_by(email: email),
      email: email,
      status: "failed",
      login_method: method,
      failed_reason: reason
    )
  rescue StandardError => e
    # Don't let login attempt logging break the authentication flow
    Rails.logger.error "Failed to log login attempt: #{e.message}"
  end

  def determine_login_method
    # Check if this is an OAuth callback
    return "google_oauth" if request.path.include?("auth/google_oauth2")

    # Default to magic link for other authentications
    "magic_link"
  end

  def login_occurred?
    # Check if user was just signed in (not just accessing a page while already signed in)
    session[:user_just_signed_in] == true
  end

  def signed_in?
    user_signed_in?
  end
end
