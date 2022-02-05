class AddParentToFacilityCategory < ActiveRecord::Migration[6.1]
  def change
    add_reference :facility_categories, :parent, null: true
  end
end
