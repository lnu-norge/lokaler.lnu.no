# frozen_string_literal: true

class RenameOrganizationBoolean < ActiveRecord::Migration[7.2]
  def change
    rename_column :users, :organization_boolean, :in_organization
  end
end
