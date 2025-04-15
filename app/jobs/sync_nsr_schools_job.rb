# frozen_string_literal: true

class SyncNsrSchoolsJob < ApplicationJob
  queue_as :syncing_data

  def perform
    SyncingData::FromNsr::RunSyncService.call
  end
end
