# frozen_string_literal: true

class SyncNsrSchoolJob < ApplicationJob
  queue_as :syncing_data

  def perform(org_number:, date_changed_at_from_nsr:)
    SyncingData::FromNsr::SyncSchoolService.call(
      org_number: org_number,
      date_changed_at_from_nsr: date_changed_at_from_nsr
    )
  end
end
