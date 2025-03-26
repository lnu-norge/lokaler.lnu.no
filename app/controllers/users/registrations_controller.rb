# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def edit
      return render :add_missing_information if current_user.missing_information?

      super
    end

    private

    def update_resource(resource, params)
      # Default Devise needs you to pass a password to update, but we don't
      # have passwords anymore.
      resource.update(params)
    end
  end
end
