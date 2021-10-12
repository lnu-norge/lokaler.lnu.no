class AddTitleToSpaceOwner < ActiveRecord::Migration[6.1]
  def change
    add_column :space_owners, :title, :string
  end
end
