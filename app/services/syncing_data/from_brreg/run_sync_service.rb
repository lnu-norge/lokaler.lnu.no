# frozen_string_literal: true

module SyncingData
  module FromBrreg
    BRREG_BASE_URL = "https://data.brreg.no/enhetsregisteret/api"
    class RunSyncService < ApplicationService
      include TaggedLogHelper
      include FetchContactInformationHelper
      include SyncStatusHelper
      include SyncSpaceContactHelper

      def initialize
        @count_logger = count_logger

        super
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
        spaces_with_organization_numbers.each do |space|
          start_sync_log(space.organization_number)
          sync_space_contacts_for(space)

          log_successful_sync(space.organization_number)
        rescue StandardError => e
          log_failed_sync(space.organization_number, e)
        end
      end

      def spaces_with_organization_numbers
        Space.where.not(organization_number: nil)
      end
    end
  end
end
