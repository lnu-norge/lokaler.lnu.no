# frozen_string_literal: true

require_relative "cache_helper"

module SyncingData
  module FromNsr
    NSR_BASE_URL = "https://data-nsr.udir.no/v4"

    class RunSyncService < ApplicationService
      include TaggedLogHelper
      include FetchSchoolsHelper

      def call
        schools_list = fetch_combined_list_of_schools
        filtered_schools = select_relevant_schools_from_list(schools_list)
        sync_jobs = sync_jobs_for_schools(filtered_schools)

        ActiveJob.perform_all_later(sync_jobs.compact)
      end

      private

      def sync_jobs_for_schools(schools)
        schools.map do |school|
          org_number = school["Organisasjonsnummer"]
          date_changed = school["DatoEndret"]

          next if school.blank? || org_number.blank? || date_changed.blank?

          SyncNsrSchoolJob.new(
            org_number: org_number,
            date_changed_at_from_nsr: date_changed
          )
        end
      end
    end
  end
end
