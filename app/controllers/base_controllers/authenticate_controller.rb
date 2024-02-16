# frozen_string_literal: true

module BaseControllers
  class AuthenticateController < ApplicationController
    before_action :authenticate_user!

    protected

    def authenticate_user!
      if user_signed_in?
        super
      else
        redirect_to new_user_registration_path
      end
    end
  end
end
