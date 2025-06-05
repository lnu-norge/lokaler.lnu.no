# frozen_string_literal: true

module Users
  class SessionsController < Devise::Passwordless::SessionsController
    def show
      # This handles the magic link token authentication
      result = super

      if user_signed_in?
        session[:user_just_signed_in] = true
      else
        # Extract email from token if possible for failed login logging
        email = extract_email_from_token(params[:id])
        log_failed_login(email || "unknown", "Invalid or expired magic link token")
      end

      result
    end

    def create
      user = resource_class.find_or_create_by!(email: create_params[:email])
      unless user.persisted?
        log_failed_login(create_params[:email], "User not found in database")
        set_flash_message!(:alert, :not_found_in_database, now: true)
        return render :new, status: devise_error_status
      end

      # Log the magic link request as an attempted login
      log_magic_link_request(user)

      send_magic_link(user)
      set_flash_message!(:success, :magic_link_sent, email: user.email)
      redirect_to(after_magic_link_sent_path_for(user), status: devise_redirect_status)
    end

    def after_magic_link_sent_path_for(_user)
      new_user_session_path
    end

    private

    def log_magic_link_request(user)
      LoginAttempt.create!(
        user: user,
        email: user.email,
        status: "pending",
        login_method: "magic_link"
      )
    rescue StandardError => e
      # Don't let logging break the authentication flow
      Rails.logger.error "Failed to log magic link request: #{e.message}"
    end

    def extract_email_from_token(token)
      return nil unless token

      # Devise Passwordless uses SignedGlobalIDTokenizer
      # The token is a signed GlobalID of the user
      user = GlobalID::Locator.locate_signed(token, for: "passwordless_login")
      user&.email
    rescue StandardError => e
      # Token is invalid, expired, or malformed
      Rails.logger.debug { "Failed to extract email from token: #{e.message}" }
      nil
    end
  end
end
