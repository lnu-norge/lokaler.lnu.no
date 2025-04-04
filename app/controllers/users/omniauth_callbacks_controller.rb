# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    def google_oauth2 # rubocop:disable Metrics/AbcSize
      user = User.from_google(email: auth.info.email, first_name: auth.info.first_name, last_name: auth.info.last_name)

      if user.present?
        remember_me(user)
        sign_out_all_scopes
        sign_in_and_redirect user
      else
        flash[:alert] =
          I18n.t "devise.omniauth_callbacks.failure", kind: "Google", reason: "#{auth.info.email} is not authorized."
        redirect_to new_user_session_path
      end
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
