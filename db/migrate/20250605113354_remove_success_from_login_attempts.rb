# frozen_string_literal: true

class RemoveSuccessFromLoginAttempts < ActiveRecord::Migration[7.2]
  def change
    remove_index :login_attempts, [:success, :attempted_at], if_exists: true
    remove_column :login_attempts, :success, :boolean
  end
end
