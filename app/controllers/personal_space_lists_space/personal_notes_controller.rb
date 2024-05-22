# frozen_string_literal: true

class PersonalSpaceListsSpace
  class PersonalNotesController < BaseControllers::AuthenticateController
    include SettablePersonalSpaceListSpaceFromParams
    before_action :set_personal_space_list_space

    def edit; end

    def update
      @personal_space_list_space.update(personal_notes_params)
      redirect_to edit_personal_space_list_space_personal_note_path(
        personal_space_list_id: @personal_space_list.id,
        space_id: @space.id,
        id: @personal_space_list_space.id
      )
    end

    private

    def personal_notes_params
      params.require(:personal_space_lists_space).permit(:personal_notes)
    end
  end
end
