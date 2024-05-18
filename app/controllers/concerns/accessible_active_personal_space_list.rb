# frozen_string_literal: true

module AccessibleActivePersonalSpaceList
  extend ActiveSupport::Concern

  private

  def access_active_personal_list
    @active_personal_space_list = current_user
                                  &.active_personal_space_list
                                  &.personal_space_list
  end
end
