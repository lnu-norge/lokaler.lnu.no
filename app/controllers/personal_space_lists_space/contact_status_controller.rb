# frozen_string_literal: true

class PersonalSpaceListsSpace
  class ContactStatusController < BaseControllers::AuthenticateController
    include SettablePersonalSpaceListSpaceFromParams
    before_action :set_personal_space_list_space

    def show; end

    def update
      @personal_space_list_space.update(contact_status_params)
      redirect_to personal_space_list_space_contact_status_path(@personal_space_list_space)
    end

    private

    def contact_status_params
      params.require(:personal_space_lists_space).permit(:contact_status)
    end
  end
end
