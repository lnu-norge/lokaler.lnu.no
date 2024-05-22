# frozen_string_literal: true

module PersonalSpaceListsSpaces
  class ContactStatusController < BaseControllers::AuthenticateController
    include SettablePersonalSpaceListSpaceFromParams
    before_action :set_personal_space_list_space

    def edit; end

    def update
      @personal_space_list_space.update(contact_status_params)
      render partial: "personal_space_lists_spaces/contact_status/form",
             locals: { personal_space_list_space: @personal_space_list_space,
                       contact_status_updated: true }
    end

    private

    def contact_status_params
      params.require(:personal_space_lists_space).permit(:contact_status)
    end
  end
end
