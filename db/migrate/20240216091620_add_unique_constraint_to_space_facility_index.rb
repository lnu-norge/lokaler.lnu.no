class AddUniqueConstraintToSpaceFacilityIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :space_facilities, %i[space_id facility_id], unique: true
  end
end
