# frozen_string_literal: true

module AccessibleActivePersonalSpaceList
  extend ActiveSupport::Concern

  private

  def access_active_personal_list
    my_personal_space_list = current_user
                             &.active_personal_space_list
                             &.personal_space_list

    if my_personal_space_list
      @active_personal_space_list = PersonalSpaceList.includes(:spaces,
                                                               :this_lists_personal_data_on_spaces)
                                                     .find(my_personal_space_list.id)
    else
      @active_personal_space_list = nil
    end
  end
end
