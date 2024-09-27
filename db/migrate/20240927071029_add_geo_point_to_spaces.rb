class AddGeoPointToSpaces < ActiveRecord::Migration[7.1]
  def change
    # Make sure we have lat and long for all spaces:
    change_column :spaces, :lng, :decimal, null: true
    change_column :spaces, :lat, :decimal, null: true

    # And add the new column (+ index) for PostGIS handling of them:
    add_column :spaces, :geo_point, :st_point, geographic: true
    add_index :spaces, :geo_point, using: :gist

    # Populate the new column with data from the old ones:
    execute <<-SQL
      UPDATE spaces
      SET geo_point = ST_SetSRID(ST_MakePoint(lng, lat), 4326)
    SQL

    # Then set the new column to NOT NULL:
    change_column :spaces, :geo_point, :st_point, geographic: true, null: false
  end
end
