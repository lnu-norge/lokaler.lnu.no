class ChangeSpaceOwnerToSpaceGroup < ActiveRecord::Migration[6.1]
  def change
    rename_table :space_owners, :space_groups
    rename_column :space_contacts, :space_owner_id, :space_group_id
    rename_column :spaces, :space_owner_id, :space_group_id
  end
end
