# frozen_string_literal: true

namespace :sync do
  desc "Fetch fresh school data from NSR and sync with spaces"
  task schools_from_nsr: :environment do
    SyncingData::FromNsr::RunSyncService.call
  end
end
