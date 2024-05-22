class AddPrimaryKeyToPersonalSpaceListsSpaces < ActiveRecord::Migration[7.1]
  def change
    change_table :personal_space_lists_spaces do |t|
      t.primary_key :id
    end
  end
end
