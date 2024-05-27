class CreatePersonalDataOnSpaceInLists < ActiveRecord::Migration[7.1]
  def change
    create_table :personal_data_on_space_in_lists, primary_key: [:space_id, :personal_space_list_id] do |t|
      t.integer :contact_status, default: 0, null: false
      t.text :personal_notes
      t.belongs_to :space, null: false, foreign_key: true
      t.belongs_to :personal_space_list, null: false, foreign_key: true

      t.timestamps
    end

    PersonalSpaceListsSpace.all.each do |personal_space_list_space|
      PersonalDataOnSpaceInList.find_or_create_by(
        personal_space_list: personal_space_list_space.personal_space_list,
        space: personal_space_list_space.space
      )
    end

    add_index :personal_data_on_space_in_lists, [:space_id, :personal_space_list_id], unique: true, name: 'index_personal_data_on_space_in_lists_on_space_and_list'
  end
end
