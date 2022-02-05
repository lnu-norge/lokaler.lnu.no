class RemoveOrganization < ActiveRecord::Migration[6.1]
  def change
    remove_reference :reviews, :organization
    drop_table :organizations_users
    drop_table :organizations
  end
end
