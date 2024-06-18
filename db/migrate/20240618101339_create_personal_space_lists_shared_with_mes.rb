class CreatePersonalSpaceListsSharedWithMes < ActiveRecord::Migration[7.1]
  def change
    create_table :personal_space_lists_shared_with_mes do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :personal_space_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
