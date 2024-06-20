class AddTitleToPersonalSpaceList < ActiveRecord::Migration[7.1]
  def change
    add_column :personal_space_lists, :title, :string
  end
end
