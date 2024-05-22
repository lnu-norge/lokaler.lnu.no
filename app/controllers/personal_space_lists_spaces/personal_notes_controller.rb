# frozen_string_literal: true

module PersonalSpaceListsSpaces
  class PersonalNotesController < BaseControllers::AuthenticateController
    include SettablePersonalSpaceListSpaceFromParams
    before_action :set_personal_space_list_space

    def edit; end

    def update
      @personal_space_list_space.update(personal_notes_params)
      flash.now[:notice] = t("personal_space_lists.notes_saved")
      render :edit, locals: { personal_space_list: @personal_space_list }
    end

    private

    def personal_notes_params
      params.require(:personal_space_lists_space).permit(:personal_notes)
    end
  end
end
