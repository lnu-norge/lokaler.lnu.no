# frozen_string_literal: true

class CreateLoginAttempts < ActiveRecord::Migration[7.2]
  def change
    create_table :login_attempts do |t|
      t.references :user, null: true, foreign_key: true
      t.string :email, null: false
      t.boolean :success, null: false, default: false
      t.string :login_method, null: false
      t.string :failed_reason
      t.datetime :attempted_at, null: false

      t.timestamps
    end

    add_index :login_attempts, :email
    add_index :login_attempts, :attempted_at
    add_index :login_attempts, [:success, :attempted_at]
  end
end
