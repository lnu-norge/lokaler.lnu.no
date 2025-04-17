# frozen_string_literal: true

class SyncBrregContactInformationJob < ApplicationJob
  queue_as :syncing_data

  def perform
    SyncingData::FromBrreg::RunSyncService.call
  end
end
