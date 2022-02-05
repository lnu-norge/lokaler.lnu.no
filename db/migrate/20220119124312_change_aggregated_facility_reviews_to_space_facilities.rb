class ChangeAggregatedFacilityReviewsToSpaceFacilities < ActiveRecord::Migration[6.1]
  def change
    rename_table :aggregated_facility_reviews, :space_facilities
  end
end
