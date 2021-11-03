class AddIndexToFacilityReview < ActiveRecord::Migration[6.1]
  def change
    add_index :facility_reviews, [:review_id, :facility_id], unique: true
  end
end
