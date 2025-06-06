# frozen_string_literal: true

module SyncingData
  module FromBrreg
    BRREG_BASE_URL = "https://data.brreg.no/enhetsregisteret/api"
    class RunSyncService < ApplicationService
      include TaggedLogHelper
      include FetchContactInformationHelper
      include SyncStatusHelper
      include SyncSpaceContactHelper

      def initialize(force_fresh_syncs: false) # rubocop:disable Lint/MissingSuper
        @count_logger = count_logger
        @force_fresh_sync = force_fresh_syncs
        @time_between_syncs = 7.days
      end

      def call
        @count_logger.start
        sync_spaces
        @count_logger.stop
      end

      private

      def count_logger
        @count_logger ||= SyncingData::Shared::CountLogger.new(
          name: "BRREG sync",
          limit_versions_to_user_id: Robot.brreg.id,
          logger: rails_logger_with_tags
        )
      end

      def sync_spaces
        spaces = spaces_to_sync

        logger.debug "#{spaces.count} spaces will be synced"
        spaces.each_with_index do |space, index|
          logger.debug "Syncing space #{index + 1} of #{spaces.count} (space_id: #{space.id})"

          start_sync_log(space.organization_number)
          sync_space_contacts_for(space)

          log_successful_sync(space.organization_number)
        rescue StandardError => e
          log_failed_sync(space.organization_number, e)
        end
        logger.debug("Finished syncing")
      end

      def spaces_to_sync
        logger.debug "#{spaces_that_can_be_synced.count} spaces could be synced."
        return spaces_that_can_be_synced if @force_fresh_sync

        logger.debug "Removing any that have synced in the last #{@time_between_syncs.in_days.to_i} days"

        spaces_that_can_be_synced.reject do |space|
          recently_synced_successfully?(space)
        end
      end

      def spaces_that_can_be_synced
        spaces_with_organization_numbers.reject do |space|
          sync_not_possible_for(space)
        end
      end

      def recently_synced_successfully?(space)
        return false if space.organization_number.blank?

        Admin::SyncStatus
          .where(id_from_source: space.organization_number, source: "brreg")
          .exists?(last_successful_sync_at: @time_between_syncs.ago..)
      end

      def sync_not_possible_for(space)
        return true if space.organization_number.blank?
        return true unless space.organization_number.match?(/\d{9}/)
        return true if space.organization_number.match?(/U\d+/) # Utlandet

        false
      end

      def spaces_with_organization_numbers
        Space.where.not(organization_number: nil)
      end
    end
  end
end
