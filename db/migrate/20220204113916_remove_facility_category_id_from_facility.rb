class RemoveFacilityCategoryIdFromFacility < ActiveRecord::Migration[6.1]
  def change
    remove_column :facilities, :facility_category_id
  end
end
