class CreateSpaceTypesFacilities < ActiveRecord::Migration[6.1]
  def change
    create_table :space_types_facilities do |t|
      t.references :space_type, null: false, foreign_key: true
      t.references :facility, null: false, foreign_key: true

      t.timestamps
    end
  end
end
