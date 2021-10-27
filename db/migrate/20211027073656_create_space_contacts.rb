# frozen_string_literal: true

class CreateSpaceContacts < ActiveRecord::Migration[6.1]

  def change
    create_table :space_contacts do |t|
      t.string :title
      t.string :telephone
      t.string :telephone_opening_hours
      t.string :email
      t.string :url
      t.text :description
      t.integer :priority
      t.bigint :space_id, null: true, foreign_key: true
      t.bigint :space_owner_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end
