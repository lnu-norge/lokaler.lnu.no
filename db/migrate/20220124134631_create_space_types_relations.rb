class CreateSpaceTypesRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :space_types_relations do |t|
      t.references :space_type, null: false, foreign_key: true
      t.references :space, null: false, foreign_key: true


      t.timestamps
    end

    execute <<~SQL
              INSERT INTO space_types_relations (space_type_id, space_id, created_at, updated_at)
                SELECT space_type_id, id, NOW(), NOW()
                  FROM spaces
            SQL

    remove_reference :spaces, :space_type
  end
end
