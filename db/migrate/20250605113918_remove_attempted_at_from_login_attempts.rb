# frozen_string_literal: true

class RemoveAttemptedAtFromLoginAttempts < ActiveRecord::Migration[7.2]
  def change
    remove_index :login_attempts, :attempted_at, if_exists: true
    remove_column :login_attempts, :attempted_at, :datetime
  end
end
