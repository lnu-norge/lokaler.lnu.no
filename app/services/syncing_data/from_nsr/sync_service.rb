# frozen_string_literal: true

require_relative "nsr_cache_helper"

module SyncingData
  module FromNsr
    NSR_BASE_URL = "https://data-nsr.udir.no/v4"

    class SyncService < ApplicationService
      include NsrProcessSchoolsHelper
      include NsrFetchSchoolsHelper
      include NsrCacheHelper

      def call
        schools = fetch_all_schools_and_data

        process_list_of_schools(schools)
      end
    end
  end
end
