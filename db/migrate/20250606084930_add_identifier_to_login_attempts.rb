# frozen_string_literal: true

class AddIdentifierToLoginAttempts < ActiveRecord::Migration[7.2]
  def change
    add_column :login_attempts, :identifier, :string
    
    # Update existing records with email as identifier
    reversible do |dir|
      dir.up do
        execute "UPDATE login_attempts SET identifier = email WHERE email IS NOT NULL"
        execute "UPDATE login_attempts SET identifier = 'unknown' WHERE identifier IS NULL"
      end

      dir.down do
        execute "UPDATE login_attempts SET email = identifier WHERE email IS NULL"
      end
    end
    
    change_column_null :login_attempts, :identifier, false
    remove_column :login_attempts, :email
    remove_index :login_attempts, :status
    add_index :login_attempts, [:identifier, :login_method]
  end
end
