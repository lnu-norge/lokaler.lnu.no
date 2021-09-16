# frozen_string_literal: true

class CreateSpaces < ActiveRecord::Migration[6.1]
  def change
    create_table :spaces do |t|
      t.string :address
      t.string :lat
      t.string :long
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
