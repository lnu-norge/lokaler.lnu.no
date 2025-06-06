# frozen_string_literal: true

module Users
  class SessionsController < Devise::Passwordless::SessionsController
    include LoginAttemptLogger

    def create
      user = resource_class.find_or_create_by!(email: create_params[:email])
      unless user.persisted?
        log_failed_login_by(create_params[:email], reason: "User not found in database", login_method: "magic_link")
        set_flash_message!(:alert, :not_found_in_database, now: true)
        return render :new, status: devise_error_status
      end

      # Log the magic link request as an attempted login
      send_and_log_magic_link(user)

      set_flash_message!(:success, :magic_link_sent, email: user.email)
      redirect_to(after_magic_link_sent_path_for(user), status: devise_redirect_status)
    end

    def after_magic_link_sent_path_for(_user)
      new_user_session_path
    end

    private

    def send_and_log_magic_link(user)
      email_message = send_magic_link(user)
      log_magic_link_request(email_message:, user:)
    end

    def log_magic_link_request(email_message:, user:)
      identifier = extract_identifier_from(email_message)
      log_pending_login_by(identifier, user:, login_method: "magic_link")
    rescue StandardError => e
      Rails.logger.error "Failed to log magic link request: #{e.message}"
    end

    def extract_identifier_from(email_message)
      html_part = email_message.parts.find { |part| part.content_type.include?("text/html") }
      html_body = html_part.body.decoded
      magic_link_from_html = html_body.match(/href="(.+)"/)[1]
      magic_link_from_html.gsub!("&amp;", "&")

      # extract
      URI.parse(magic_link_from_html).query
    end
  end
end
