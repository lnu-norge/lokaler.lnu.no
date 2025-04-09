# frozen_string_literal: true

class AddIdFromSourceToSyncStatus < ActiveRecord::Migration[7.2]
  def change
    add_column :sync_statuses, :id_from_source, :string, null: false
    change_column_null :sync_statuses, :space_id, true

    add_index :sync_statuses, [:id_from_source, :source], unique: true
    add_index :sync_statuses, :source
  end
end
