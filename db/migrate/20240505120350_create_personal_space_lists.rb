class CreatePersonalSpaceLists < ActiveRecord::Migration[7.1]
  def change
    create_table :personal_space_lists do |t|
      t.belongs_to :user
      t.timestamps
    end

    create_join_table :personal_space_lists, :spaces do |t|
      t.index :personal_space_list_id
      t.index :space_id
    end
  end
end
