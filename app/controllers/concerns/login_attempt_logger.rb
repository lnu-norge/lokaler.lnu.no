# frozen_string_literal: true

module LoginAttemptLogger
  extend ActiveSupport::Concern

  private

  def log_pending_login_by(identifier, login_method:, user: nil)
    throw "No identifier present" if identifier.blank?

    LoginAttempt.create!(
      identifier:,
      user:,
      login_method:,
      status: "pending"
    )
  rescue StandardError => e
    # Don't let login attempt logging break the authentication flow
    Rails.logger.error "Failed to log login attempt: #{e.message}"
  end

  def log_successful_login_by(identifier, login_method:, user: current_user)
    login_attempt = existing_or_new_login_attempt(identifier:, login_method:)
    login_attempt.update(
      status: "successful",
      user:,
      failed_reason: nil
    )

    login_attempt.save
  rescue StandardError => e
    # Don't let login attempt logging break the authentication flow
    Rails.logger.error "Failed to log login attempt: #{e.message}"
  end

  def log_failed_login_by(identifier, reason:, login_method:)
    throw "No token present" if identifier.blank?

    login_attempt = existing_or_new_login_attempt(identifier:, login_method:)
    login_attempt.update(
      status: "failed",
      failed_reason: reason
    )

    login_attempt.save
  rescue StandardError => e
    # Don't let login attempt logging break the authentication flow
    Rails.logger.error "Failed to log login attempt: #{e.message}"
  end

  def existing_or_new_login_attempt(identifier:, login_method:)
    last_matching_login_attempt = LoginAttempt.where(identifier:, login_method:).last

    return last_matching_login_attempt if login_attempt_valid_and_recent(last_matching_login_attempt)

    LoginAttempt.new(
      identifier:,
      login_method:
    )
  end

  def login_attempt_valid_and_recent(attempt)
    return false if attempt.blank?
    return false unless attempt.persisted?
    return false if attempt.created_at < 1.day.ago

    true
  end
end
