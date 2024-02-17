# frozen_string_literal: true

module BaseControllers
  class AuthenticateController < ApplicationController
    before_action :authenticate_user!
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

    def authenticate_user!
      if user_signed_in?
        super
      else
        redirect_to new_user_session_path
      end
    end
  end
end
