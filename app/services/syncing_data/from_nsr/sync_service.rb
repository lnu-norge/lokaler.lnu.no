# frozen_string_literal: true

require_relative "cache_helper"

module SyncingData
  module FromNsr
    NSR_BASE_URL = "https://data-nsr.udir.no/v4"

    class SyncService < ApplicationService
      include FetchSchoolsHelper
      include ProcessSchoolsHelper

      def initialize
        @count_logger = SyncingData::Shared::CountLogger.new(
          name: "NSR sync",
          limit_versions_to_user_id: Robot.nsr.id
        )

        super
      end

      def call
        @count_logger.start
        schools = fetch_all_schools_and_data
        process_schools_and_save_space_data(schools)
        @count_logger.stop
      end
    end
  end
end
