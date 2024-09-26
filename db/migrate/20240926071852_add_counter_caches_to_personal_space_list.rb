class AddCounterCachesToPersonalSpaceList < ActiveRecord::Migration[7.1]
  def up
    add_column :personal_space_lists, :space_count, :integer, default: 0
    add_column :personal_space_lists, :space_not_contacted_count, :integer, default: 0
    add_column :personal_space_lists, :space_said_no_count, :integer, default: 0
    add_column :personal_space_lists, :space_said_maybe_count, :integer, default: 0
    add_column :personal_space_lists, :space_said_yes_count, :integer, default: 0

    # Update the counter caches
    execute <<-SQL
      UPDATE personal_space_lists
      SET
        space_count = (
          SELECT COUNT(*)
          FROM personal_space_lists_spaces
          WHERE personal_space_lists_spaces.personal_space_list_id = personal_space_lists.id
        ),
        space_not_contacted_count = (
          SELECT COUNT(*)
          FROM personal_space_lists_spaces
          JOIN personal_data_on_space_in_lists ON
            personal_data_on_space_in_lists.space_id = personal_space_lists_spaces.space_id AND
            personal_data_on_space_in_lists.personal_space_list_id = personal_space_lists_spaces.personal_space_list_id
          WHERE personal_space_lists_spaces.personal_space_list_id = personal_space_lists.id
            AND personal_data_on_space_in_lists.contact_status = 0
        ),
        space_said_no_count = (
          SELECT COUNT(*)
          FROM personal_space_lists_spaces
          JOIN personal_data_on_space_in_lists ON
            personal_data_on_space_in_lists.space_id = personal_space_lists_spaces.space_id AND
            personal_data_on_space_in_lists.personal_space_list_id = personal_space_lists_spaces.personal_space_list_id
          WHERE personal_space_lists_spaces.personal_space_list_id = personal_space_lists.id
            AND personal_data_on_space_in_lists.contact_status = 1
        ),
        space_said_maybe_count = (
          SELECT COUNT(*)
          FROM personal_space_lists_spaces
          JOIN personal_data_on_space_in_lists ON
            personal_data_on_space_in_lists.space_id = personal_space_lists_spaces.space_id AND
            personal_data_on_space_in_lists.personal_space_list_id = personal_space_lists_spaces.personal_space_list_id
          WHERE personal_space_lists_spaces.personal_space_list_id = personal_space_lists.id
            AND personal_data_on_space_in_lists.contact_status = 2
        ),
        space_said_yes_count = (
          SELECT COUNT(*)
          FROM personal_space_lists_spaces
          JOIN personal_data_on_space_in_lists ON
            personal_data_on_space_in_lists.space_id = personal_space_lists_spaces.space_id AND
            personal_data_on_space_in_lists.personal_space_list_id = personal_space_lists_spaces.personal_space_list_id
          WHERE personal_space_lists_spaces.personal_space_list_id = personal_space_lists.id
            AND personal_data_on_space_in_lists.contact_status = 3
        )
    SQL
  end

  def down
    remove_column :personal_space_lists, :space_count
    remove_column :personal_space_lists, :space_not_contacted_count
    remove_column :personal_space_lists, :space_said_no_count
    remove_column :personal_space_lists, :space_said_maybe_count
    remove_column :personal_space_lists, :space_said_yes_count
  end
end
