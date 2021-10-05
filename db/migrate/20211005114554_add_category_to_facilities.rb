class AddCategoryToFacilities < ActiveRecord::Migration[6.1]
  def change
    create_table :facility_categories do |t|
      t.string :title, null: false
      t.timestamps
    end
    add_reference :facilities, :facility_category, index: true, foreign_key: true
  end
end
