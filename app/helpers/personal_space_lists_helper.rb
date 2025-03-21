# frozen_string_literal: true

module PersonalSpaceListsHelper
  def dom_id_for_list_and_space(personal_space_list, space)
    "personal_space_list_#{personal_space_list&.id || 'new'}__for_space_#{space.id}_updates_here"
  end

  def dom_id_for_list_status_for_space(space)
    "list_status_for_space_#{space.id}_updates_here"
  end

  def dom_id_for_list_status_for_space_in_map_marker(space)
    "list_status_for_space_#{space.id}_in_map_marker"
  end

  def dom_id_for_active_list_updates_here
    "active_list_updates_here"
  end

  def dom_id_for_space_list_status_and_notes_for_space(space)
    "space_list_status_and_notes_for_space_#{space.id}"
  end

  def dom_id_for_space_list_status_and_notes_for_space_in_table_row(space)
    "space_list_status_and_notes_for_space_#{space.id}_in_table_row"
  end

  def dom_id_space_list_icons_for(personal_space_list, scope: "standard")
    "space_list_icons_for_personal_space_list_#{personal_space_list.id}_scope_#{scope}"
  end

  def dom_id_for_list_status_in_filter_button
    "list_status_in_filter_button"
  end
end
