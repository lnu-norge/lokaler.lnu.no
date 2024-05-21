class AddContactStatusAndPersonalNotesToPersonalSpaceListsSpaces < ActiveRecord::Migration[7.1]
  def change
    change_table :personal_space_lists_spaces do |t|
      t.integer :contact_status
      t.text :personal_notes
    end
  end
end
