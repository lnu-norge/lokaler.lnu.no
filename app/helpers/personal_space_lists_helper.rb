# frozen_string_literal: true

module PersonalSpaceListsHelper
  def dom_id_for_list_and_space(personal_space_list, space)
    "personal_space_list_#{personal_space_list&.id || 'new'}__for_space_#{space.id}_updates_here"
  end

  def dom_id_for_list_status_for_space(space)
    "list_status_for_space_#{space.id}_updates_here"
  end

  def dom_id_for_active_list_updates_here
    "active_list_updates_here"
  end
end
