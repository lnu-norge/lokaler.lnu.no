# frozen_string_literal: true

class CreateFacilities < ActiveRecord::Migration[6.1]
  def change
    create_table :facilities do |t|
      t.string :title
      t.references :space, null: false, foreign_key: true

      t.timestamps
    end
  end
end
