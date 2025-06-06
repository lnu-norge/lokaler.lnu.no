# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable
    include LoginAttemptLogger

    def google_oauth2 # rubocop:disable Metrics/AbcSize
      user = User.from_google(email: auth.info.email, first_name: auth.info.first_name, last_name: auth.info.last_name)

      if user.present?
        remember_me(user)
        sign_out_all_scopes
        log_successful_login_by(auth.info.email, login_method: "google_oauth", user:)
        sign_in_and_redirect user
      else
        log_failed_login_by(auth.info.email, reason: "User not authorized for Google OAuth",
                                             login_method: "google_oauth")
        flash[:alert] =
          I18n.t "devise.omniauth_callbacks.failure", kind: "Google", reason: "#{auth.info.email} is not authorized."
        redirect_to new_user_session_path
      end
    end

    def failure
      # Handle OAuth failure
      error_info = request.env["omniauth.error"]
      email = request.env.dig("omniauth.auth", "info", "email") || "unknown"

      log_failed_login_by(email, reason: "OAuth failure: #{error_info&.message || 'Unknown error'}",
                                 login_method: "google_oauth")

      super
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      new_user_session_path
    end

    private

    def auth
      @auth ||= request.env["omniauth.auth"]
    end
  end
end
