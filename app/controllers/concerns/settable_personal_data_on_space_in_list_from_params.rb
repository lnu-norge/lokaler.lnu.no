# frozen_string_literal: true

module SettablePersonalDataOnSpaceInListFromParams
  extend ActiveSupport::Concern
  include AccessToPersonalSpaceListVerifiable

  private

  def set_personal_data_on_space_in_list
    set_personal_space_list
    set_space
    verify_that_user_has_access_to_personal_space_list

    @personal_data_on_space_in_list = PersonalDataOnSpaceInList.find_or_create_by(
      personal_space_list: @personal_space_list,
      space: @space
    )
  end

  def set_personal_space_list
    @personal_space_list = PersonalSpaceList.find(params[:personal_space_list_id])
  end

  def set_space
    @space = Space.find(params[:space_id])
  end
end
