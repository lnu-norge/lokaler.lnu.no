# frozen_string_literal: true

namespace :sync do
  desc "Fetch fresh space contact data from BRREG and sync with spaces"
  task space_contacts_from_brreg: :environment do
    SyncingData::FromBrreg::RunSyncService.call
  end
end
