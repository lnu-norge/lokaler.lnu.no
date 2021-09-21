# frozen_string_literal: true

class CreateFacilityReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :facility_reviews do |t|
      t.references :facility, null: false, foreign_key: true
      t.references :space, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :review, null: true, foreign_key: true
      t.integer :experience

      t.timestamps
    end
  end
end
