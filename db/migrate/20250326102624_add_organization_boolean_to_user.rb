# frozen_string_literal: true

class AddOrganizationBooleanToUser < ActiveRecord::Migration[7.2]
  def up
    # Change the name of User.organization to User.organization_name
    rename_column :users, :organization, :organization_name
    # Make it not required, with no default (previously "")
    change_column_null :users, :organization_name, true
    change_column_default :users, :organization_name, nil

    # Create a new column for if the user has an organization or not
    add_column :users, :organization_boolean, :boolean

    # Populate the new column with true for all users with a non-blank organization
    User.where.not(organization_name: "").update_all(organization_boolean: true)

    # Do not populate it for blank organizations, as we want to ask them
    # for their organization on the next login.
  end

  def down
    # Change the name of User.organization_name to User.organization
    rename_column :users, :organization_name, :organization
    # Make it required, with "" as default
    change_column_null :users, :organization, false, ""
    change_column_default :users, :organization, ""

    # Populate with "" for all users with an organization_boolean of false or nil
    User.where(organization_boolean: false).update_all(organization: "")
    User.where(organization_boolean: nil).update_all(organization: "")

    # Drop the organization_boolean column
    remove_column :users, :organization_boolean
  end
end
