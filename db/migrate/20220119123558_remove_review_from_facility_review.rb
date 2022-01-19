class RemoveReviewFromFacilityReview < ActiveRecord::Migration[6.1]
  def change
    remove_reference :facility_reviews, :review
  end
end
