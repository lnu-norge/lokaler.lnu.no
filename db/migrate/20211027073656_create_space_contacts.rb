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
      t.belongs_to :space, null: true, foreign_key: true
      t.belongs_to :space_owner, null: true, foreign_key: true

      t.timestamps
    end
  end
end
