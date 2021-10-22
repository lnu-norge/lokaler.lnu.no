# frozen_string_literal: true

class AuthenticateController < ApplicationController
  before_action :authenticate_user!

  protected

  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to new_user_session_path
    end
  end
end
