# frozen_string_literal: true

module SettablePersonalSpaceListSpaceFromParams
  extend ActiveSupport::Concern

  private

  def set_personal_space_list_space
    set_personal_space_list
    set_space

    return @personal_space_list_space = PersonalSpaceListsSpace.find(params[:id]) if params[:id].present?

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
end
