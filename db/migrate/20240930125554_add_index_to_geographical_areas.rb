class AddIndexToGeographicalAreas < ActiveRecord::Migration[7.1]
  def change
    add_index :geographical_areas, :geo_area, using: :gist
  end
end
