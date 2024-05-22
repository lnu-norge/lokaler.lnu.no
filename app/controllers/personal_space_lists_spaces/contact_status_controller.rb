# frozen_string_literal: true

module PersonalSpaceListsSpaces
  class ContactStatusController < BaseControllers::AuthenticateController
    include SettablePersonalSpaceListSpaceFromParams
    before_action :set_personal_space_list_space

    def edit; end

    def update
      @personal_space_list_space.update(contact_status_params)
      flash.now[:notice] = t("personal_space_lists.contact_status_saved")
      render :edit, locals: { personal_space_list: @personal_space_list }
    end

    private

    def contact_status_params
      params.require(:personal_space_lists_space).permit(:contact_status)
    end
  end
end
