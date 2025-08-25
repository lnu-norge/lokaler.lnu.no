# frozen_string_literal: true

module PersonalSpaceLists
  class ContactStatusController < BaseControllers::AuthenticateController
    include SettablePersonalDataOnSpaceInListFromParams

    before_action :set_personal_data_on_space_in_list

    def edit; end

    def update
      @personal_data_on_space_in_list.update(contact_status_params)
      render partial: "personal_space_lists/contact_status/form",
             locals: { personal_data_on_space_in_list: @personal_data_on_space_in_list,
                       contact_status_updated: true }
    end

    private

    def contact_status_params
      params.expect(personal_data_on_space_in_list: [:contact_status])
    end
  end
end
