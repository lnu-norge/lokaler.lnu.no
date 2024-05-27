# frozen_string_literal: true

module SettablePersonalSpaceListSpaceFromParams
  extend ActiveSupport::Concern

  private

  def set_personal_space_list_space
    set_personal_space_list
    set_space

    return if personal_space_list_space_settable_from_from_id

    @personal_space_list_space = PersonalSpaceListsSpace.find_or_create_by(
      personal_space_list: @personal_space_list,
      space: @space
    )
  end

  def personal_space_list_space_settable_from_from_id
    return false if params[:id].blank?

    @personal_space_list_space = PersonalSpaceListsSpace.find_by(id: params[:id])

    return false if @personal_space_list_space.blank?

    true
  end

  def set_personal_space_list
    @personal_space_list = PersonalSpaceList.find(params[:personal_space_list_id])

    return if (@personal_space_list.user == current_user) || current_user.admin?

    redirect_to personal_space_lists_url, alert: t("personal_space_lists.no_access")
  end

  def set_space
    @space = Space.find(params[:space_id])
  end
end
