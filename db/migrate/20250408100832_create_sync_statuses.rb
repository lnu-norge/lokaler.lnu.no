# frozen_string_literal: true

class CreateSyncStatuses < ActiveRecord::Migration[7.2]
  def change
    create_table :sync_statuses do |t|
      t.belongs_to :space, null: false, foreign_key: true
      t.datetime :last_successful_sync_at
      t.datetime :last_attempted_sync_at
      t.boolean :last_attempt_was_successful
      t.string :source, null: false

      t.timestamps
    end
    
    # Add unique index on the combination of space_id and source
    add_index :sync_statuses, [:space_id, :source], unique: true
  end
end
