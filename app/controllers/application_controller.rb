# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Devise::RedirectAfterSignInOrOut
  include LoginAttemptLogger

  before_action :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :track_user_presence

  protected

  def configure_permitted_parameters
    keys = %i[first_name last_name organization_name in_organization]
    devise_parameter_sanitizer.permit(:sign_up, keys:)
    devise_parameter_sanitizer.permit(:account_update, keys:)
  end

  private

  def track_user_presence
    return unless user_signed_in?

    UserPresenceLog.log_user_presence(current_user)
  rescue StandardError => e
    # Don't let presence logging break the application
    Rails.logger.error "Failed to log user presence: #{e.message}"
  end
end
