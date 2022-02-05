# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  private

  def storable_location?
    if devise_controller? && action_name == "edit" && current_user.nil?
      redirect_to new_user_session_path
      return true
    end

    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  protected

  def configure_permitted_parameters
    keys = [:first_name, :last_name, :organization]
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys)
  end
end
