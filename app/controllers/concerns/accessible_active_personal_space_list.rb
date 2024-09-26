# frozen_string_literal: true

module AccessibleActivePersonalSpaceList
  extend ActiveSupport::Concern

  private

  def access_active_personal_list
    my_personal_space_list = current_user
                             &.active_personal_space_list
                             &.personal_space_list

    return @active_personal_space_list = nil if my_personal_space_list.blank?

    @active_personal_space_list = PersonalSpaceList.includes(:spaces,
                                                             {
                                                               personal_space_lists_spaces:
                                                                :personal_data_on_space_in_lists
                                                             })
                                                   .find(my_personal_space_list.id)
  end
end
