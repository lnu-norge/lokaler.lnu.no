# frozen_string_literal: true

namespace :sync do
  desc "Fetch space contact data from BRREG and sync with spaces"
  task brreg_space_contacts: :environment do
    SyncingData::FromBrreg::RunSyncService.call
  end

  desc "Fetch data from BRREG even if it has been synced recently, and sync with spaces"
  task force_brreg_space_contacts: :environment do
    SyncingData::FromBrreg::RunSyncService.call(time_between_syncs: 0.seconds)
  end
end
