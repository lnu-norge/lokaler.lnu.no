# frozen_string_literal: true

class ChangeOrganizationToSpaceOwner < ActiveRecord::Migration[6.1]
  def change
    rename_table :organizations, :space_owners
    rename_column :spaces, :organization_id, :space_owner_id
  end
end
