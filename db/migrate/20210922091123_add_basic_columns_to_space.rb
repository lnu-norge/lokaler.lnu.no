# frozen_string_literal: true

class AddBasicColumnsToSpace < ActiveRecord::Migration[6.1]
  def change
    change_table :spaces, bulk: true do |t|
      # Extend basic information
      t.string :title, null: false
      # Org number for the school itself, if available
      #
      t.string :organization_number

      # Extending address:
      t.string :post_number
      t.string :post_address
      t.string :municipality_code

      # How many people does it fit? Usually based on pupil numbers
      t.integer :fits_people
    end
  end
end
