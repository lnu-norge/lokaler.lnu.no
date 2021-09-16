# frozen_string_literal: true

class CreateSpaceTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :space_types do |t|
      t.string :type_name

      t.timestamps
    end
  end
end
