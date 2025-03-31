# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Devise::RedirectAfterSignInOrOut

  before_action :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    keys = %i[first_name last_name organization_name in_organization]
    devise_parameter_sanitizer.permit(:sign_up, keys:)
    devise_parameter_sanitizer.permit(:account_update, keys:)
  end
end
