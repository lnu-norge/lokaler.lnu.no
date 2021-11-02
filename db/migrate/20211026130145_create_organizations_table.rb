# frozen_string_literal: true

class CreateOrganizationsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.integer :orgnr
      t.string :website
      t.string :logo

      t.timestamps
    end
  end
end
