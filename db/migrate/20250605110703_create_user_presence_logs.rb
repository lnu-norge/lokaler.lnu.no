# frozen_string_literal: true

class CreateUserPresenceLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :user_presence_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false

      t.timestamps
    end

    add_index :user_presence_logs, [:user_id, :date], unique: true
    add_index :user_presence_logs, :date
  end
end
