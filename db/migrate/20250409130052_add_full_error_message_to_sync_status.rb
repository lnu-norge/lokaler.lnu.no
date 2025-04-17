# frozen_string_literal: true

class AddFullErrorMessageToSyncStatus < ActiveRecord::Migration[7.2]
  def change
    add_column :sync_statuses, :full_error_message, :text
  end
end
