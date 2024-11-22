# frozen_string_literal: true

module BaseControllers
  class AuthenticateAsAdminController < AuthenticateController
    before_action :authenticate_admin!
    layout "admin/authenticated_as_admin"

    protected

    def authenticate_admin!
      authenticate_user!
      redirect_to spaces_path unless current_user.admin?
    end
  end
end
