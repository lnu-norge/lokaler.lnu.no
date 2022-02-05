class CreateFacilitiesCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :facilities_categories do |t|
      t.references :facility, null: false, foreign_key: true
      t.references :facility_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
