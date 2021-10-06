class AddIconToFacilities < ActiveRecord::Migration[6.1]
  def change
    add_column :facilities, :icon, :string
  end
end
