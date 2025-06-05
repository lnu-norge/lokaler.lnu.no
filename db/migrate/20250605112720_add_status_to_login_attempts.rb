# frozen_string_literal: true

class AddStatusToLoginAttempts < ActiveRecord::Migration[7.2]
  def change
    add_column :login_attempts, :status, :string, null: false, default: 'pending'
    add_index :login_attempts, :status
    
    # Migrate existing data
    reversible do |dir|
      dir.up do
        # Update existing records based on success field
        execute <<-SQL
          UPDATE login_attempts 
          SET status = CASE 
            WHEN success = true THEN 'successful'
            WHEN failed_reason = 'Magic link sent - pending user action' THEN 'pending'
            ELSE 'failed'
          END
        SQL
      end
    end
  end
end
