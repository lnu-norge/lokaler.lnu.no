class CreateActivePersonalSpaceLists < ActiveRecord::Migration[7.1]
  def change
    create_table :active_personal_space_lists do |t|
      t.references :user, null: false, foreign_key: true, index: {unique: true}
      t.references :personal_space_list, null: false, foreign_key: true
      t.timestamps
    end
  end
end
