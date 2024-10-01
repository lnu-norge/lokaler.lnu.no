class AddExternalSourceInfoToGeographicArea < ActiveRecord::Migration[7.1]
  def change
    add_column :geographical_areas, :unique_id_for_external_source, :string
    add_column :geographical_areas, :external_source, :string
  end
end
