# frozen_string_literal: true

module Admin
  class AdminController < AuthenticateController
    before_action :authenticate_admin!

    protected

    def authenticate_admin!
      authenticate_user!
      redirect_to spaces_path unless current_user.admin?
    end
  end
end
