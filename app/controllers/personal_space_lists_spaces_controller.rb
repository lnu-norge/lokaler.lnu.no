# frozen_string_literal: true

class PersonalSpaceListsSpacesController < BaseControllers::AuthenticateController
  before_action :set_personal_space_list_space

  # TODO: SPLIT INTO TWO CONTROLLERS WITH TWO VIEWS, ONE FOR EACH ACTION
  # That way we can have a simple show and edit view for both notes and contact status
  # and use turbo_frames for the edit view, and simple forms.
  def update_personal_notes
    @personal_space_list_space.update(personal_notes_params)
    redirect_to personal_space_list_url(@personal_space_list_space.personal_space_list)
  end

  def update_contact_status
    @personal_space_list_space.update(contact_status_params)
    redirect_to personal_space_list_url(@personal_space_list_space.personal_space_list)
  end

  private

  def set_personal_space_list_space
    set_personal_space_list
    set_space

    @personal_space_list_space = PersonalSpaceListsSpace.find_or_create_by(
      personal_space_list: @personal_space_list,
      space: @space
    )
  end

  def set_personal_space_list
    @personal_space_list = PersonalSpaceList.find(params[:personal_space_list_id])

    return if (@personal_space_list.user == current_user) || current_user.admin?

    redirect_to personal_space_lists_url, alert: t("personal_space_lists.no_access")
  end

  def set_space
    @space = Space.find(params[:space_id])
  end

  def personal_notes_params
    params.require(:personal_space_list_space).permit(:personal_notes)
  end

  def contact_status_params
    params.require(:personal_space_list_space).permit(:contact_status)
  end
end
