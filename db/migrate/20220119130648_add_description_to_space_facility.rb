class AddDescriptionToSpaceFacility < ActiveRecord::Migration[6.1]
  def change
    add_column :space_facilities, :description, :string, null: true
  end
end
