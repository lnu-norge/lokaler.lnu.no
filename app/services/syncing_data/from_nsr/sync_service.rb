# frozen_string_literal: true

require_relative "cache_helper"

module SyncingData
  module FromNsr
    NSR_BASE_URL = "https://data-nsr.udir.no/v4"

    class SyncService < ApplicationService
      include FetchSchoolsHelper
      include ProcessSchoolsHelper

      def call
        log_counts_around do
          schools = fetch_all_schools_and_data
          process_schools_and_save_space_data(schools)
        end
      end

      private

      def log_counts_around
        log_counts(context: "Start NSR sync", prefix: "Before NSR sync:")
        result = yield
        log_counts(context: "Finished NSR sync", prefix: "After NSR sync:")

        result
      end

      def log_counts(context:, prefix:) # rubocop:disable Metrics/AbcSize
        Rails.logger.info(context.to_s)
        Rails.logger.info("#{prefix} spaces: #{Space.count}")
        Rails.logger.info("#{prefix} space types: #{SpaceType.count}")
        Rails.logger.info("#{prefix} space groups: #{SpaceGroup.count}")
        Rails.logger.info("#{prefix} space contacts: #{SpaceContact.count}")
        Rails.logger.info("#{prefix} space types relations: #{SpaceTypesRelation.count}")
        Rails.logger.info("#{prefix} facilities: #{Facility.count}")
        Rails.logger.info("#{prefix} space type facilities relations: #{SpaceTypesFacility.count}")
        Rails.logger.info("#{prefix} versions made by NSR bot: #{
          PaperTrail::Version
            .where(whodunnit: Robot.nsr.id)
            .count
        }")
      end
    end
  end
end
