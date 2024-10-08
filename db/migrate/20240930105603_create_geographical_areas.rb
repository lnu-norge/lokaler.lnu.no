class CreateGeographicalAreas < ActiveRecord::Migration[7.1]
  def change
    create_table :geographical_area_types do |t|
      t.string :name
      t.references :parent, foreign_key: { to_table: :geographical_area_types }

      t.timestamps
    end

    create_table :geographical_areas do |t|
      t.string :name
      t.boolean :filterable, default: true
      t.integer :order
      t.geometry :geo_area, null: false
      t.references :parent, foreign_key: { to_table: :geographical_areas }
      t.belongs_to :geographical_area_type, foreign_key: true

      t.timestamps
    end
  end
end
