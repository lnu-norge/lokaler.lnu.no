class AddRelevantIntegerToSpaceFacility < ActiveRecord::Migration[6.1]
  def change
    add_column :space_facilities, :relevant, :boolean, default: false
  end
end
