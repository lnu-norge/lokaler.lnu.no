class AddLocationDescriptionToSpaces < ActiveRecord::Migration[6.1]
  def change
    add_column :spaces, :location_description, :text
  end
end
