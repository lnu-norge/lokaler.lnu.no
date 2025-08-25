# frozen_string_literal: true

module PersonalSpaceLists
  class PersonalNotesController < BaseControllers::AuthenticateController
    include SettablePersonalDataOnSpaceInListFromParams

    before_action :set_personal_data_on_space_in_list

    def edit; end

    def update
      @personal_data_on_space_in_list.update(personal_notes_params)
      flash.now[:notice] = t("personal_space_lists.notes_saved")
      render :edit, locals: { personal_space_list: @personal_space_list }
    end

    private

    def personal_notes_params
      params.expect(personal_data_on_space_in_list: [:personal_notes])
    end
  end
end
