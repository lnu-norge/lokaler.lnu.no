# frozen_string_literal: true

class AddErrorMessageToSyncStatus < ActiveRecord::Migration[7.2]
  def change
    add_column :sync_statuses, :error_message, :string
  end
end
