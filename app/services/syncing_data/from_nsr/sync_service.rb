# frozen_string_literal: true

require_relative "cache_helper"

module SyncingData
  module FromNsr
    NSR_BASE_URL = "https://data-nsr.udir.no/v4"

    class SyncService < ApplicationService
      include FetchSchoolsHelper
      include ProcessSchoolsHelper

      def call
        schools = fetch_all_schools_and_data
        process_schools_and_save_space_data(schools)
      end
    end
  end
end
