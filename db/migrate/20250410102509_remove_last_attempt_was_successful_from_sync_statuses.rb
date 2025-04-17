# frozen_string_literal: true

class RemoveLastAttemptWasSuccessfulFromSyncStatuses < ActiveRecord::Migration[7.2]
  def change
    remove_column :sync_statuses, :last_attempt_was_successful
  end
end
