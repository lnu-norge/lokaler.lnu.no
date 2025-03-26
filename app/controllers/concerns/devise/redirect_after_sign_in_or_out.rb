# frozen_string_literal: true

module Devise
  module RedirectAfterSignInOrOut
    extend ActiveSupport::Concern

    private

    def after_sign_in_path_for(resource_or_scope)
      return edit_user_registration_path if resource_or_scope.is_a?(User) && resource_or_scope.missing_information?

      stored_location_for(resource_or_scope) || root_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      root_path
    end
  end
end
