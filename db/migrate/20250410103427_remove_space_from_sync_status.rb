# frozen_string_literal: true

class RemoveSpaceFromSyncStatus < ActiveRecord::Migration[7.2]
  def change
    remove_index :sync_statuses, [:space_id, :source]
    remove_index :sync_statuses, :space_id
    remove_column :sync_statuses, :space_id, :integer
  end
end
