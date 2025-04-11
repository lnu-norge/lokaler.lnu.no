# frozen_string_literal: true

require_relative "cache_helper"

module SyncingData
  module FromNsr
    NSR_BASE_URL = "https://data-nsr.udir.no/v4"

    class RunSyncService < ApplicationService
      include TaggedLogHelper
      include FetchSchoolsHelper
      include ProcessSchoolsHelper

      def initialize
        @count_logger = count_logger

        super
      end

      def call
        @count_logger.start
        schools = fetch_all_schools_and_data
        process_schools_and_save_space_data(schools)
        @count_logger.stop
      end

      private

      def count_logger
        @count_logger ||= SyncingData::Shared::CountLogger.new(
          name: "NSR sync",
          limit_versions_to_user_id: Robot.nsr.id,
          logger: rails_logger_with_tags
        )
      end
    end
  end
end
