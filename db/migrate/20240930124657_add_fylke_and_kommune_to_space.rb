class AddFylkeAndKommuneToSpace < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :fylke_id, :bigint
    add_column :spaces, :kommune_id, :bigint

    add_foreign_key :spaces, :geographical_areas, column: :fylke_id
    add_foreign_key :spaces, :geographical_areas, column: :kommune_id

    add_index :spaces, :fylke_id
    add_index :spaces, :kommune_id
  end
end
