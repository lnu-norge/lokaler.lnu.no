class AddShareableToPersonalSpaceList < ActiveRecord::Migration[7.1]
  def change
    add_column :personal_space_lists, :shared_with_public, :boolean, default: false
  end
end
