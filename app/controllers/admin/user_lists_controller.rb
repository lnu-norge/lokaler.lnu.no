# frozen_string_literal: true

module Admin
  class UserListsController < BaseControllers::AuthenticateAsAdminController
    def index
      @all_users = User.all
    end
  end
end
