# frozen_string_literal: true

module SettablePersonalDataOnSpaceInListFromParams
  extend ActiveSupport::Concern

  private

  def set_personal_data_on_space_in_list
    set_personal_space_list
    set_space

    @personal_data_on_space_in_list = PersonalDataOnSpaceInList.find_or_create_by(
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
