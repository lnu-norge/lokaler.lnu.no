# frozen_string_literal: true

class AdminAuthenticateController < AuthenticateController
  before_action :authenticate_admin!

  protected

  def authenticate_admin!
    authenticate_user!
    redirect_to spaces_path unless current_user.admin?
  end
end
