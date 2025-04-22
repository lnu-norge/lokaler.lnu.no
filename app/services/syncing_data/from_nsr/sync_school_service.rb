# frozen_string_literal: true

require_relative "cache_helper"

module SyncingData
  module FromNsr
    NSR_BASE_URL = "https://data-nsr.udir.no/v4" unless defined?(NSR_BASE_URL)

    class SyncSchoolService < ApplicationService
      include TaggedLogHelper
      include CacheHelper
      include ProcessSchoolsHelper
      include SyncStatusHelper
      include FetchSchoolsHelper

      attr_reader :org_number, :date_changed_at_from_nsr

      def initialize(org_number:, date_changed_at_from_nsr:)
        @org_number = org_number
        @date_changed_at_from_nsr = date_changed_at_from_nsr
        super()
      end

      def call
        return if org_number.blank?

        sync_school_data
      end

      private

      def sync_school_data
        school_data = details_about_school(
          org_number:,
          date_changed_at_from_nsr:
        )
        return if school_data.blank?

        process_school_and_save_space_data(school_data)
      end
    end
  end
end
