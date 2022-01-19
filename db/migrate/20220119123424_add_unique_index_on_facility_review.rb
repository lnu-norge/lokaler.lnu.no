class AddUniqueIndexOnFacilityReview < ActiveRecord::Migration[6.1]
  def change
    # A user can only have one review for a space
    add_index :facility_reviews, [:space_id, :user_id], unique: true
  end
end
