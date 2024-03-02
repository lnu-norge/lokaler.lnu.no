class AddIndexesForAggregations < ActiveRecord::Migration[7.1]
  def change
    # Add index for facility_reviews on space_id and facility_id
    add_index :facility_reviews, %i[space_id facility_id]

    # Add index for space types facilities on space_type_id and facility_id
    add_index :space_types_facilities, [:space_type_id, :facility_id], unique: true
  end
end
