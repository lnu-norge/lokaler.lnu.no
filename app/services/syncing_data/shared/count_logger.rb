# frozen_string_literal: true

module SyncingData
  module Shared
    class CountLogger
      def initialize(
        name:,
        limit_versions_to_user_id:,
        logger: Rails.logger

      )
        @logger = logger
        @user_id_to_limit_versions_to = limit_versions_to_user_id

        @log_counts_before = {}
        @log_counts_after = {}
        @log_counts_diff = {}
        @log_updated_during = {}
        @sync_started_at = nil

        @context_string = "#{name} started at #{Time.current}"
        @prefix_for_counts_before = "Before #{name}:"
        @prefix_for_counts_after = "After #{name}:"
        @prefix_for_counts_diff = "Difference after #{name}:"
        @prefix_for_updated_during = "Updated during #{name}:"
      end

      def start
        @logger.info("Starting count for: #{@context_string}")
        @sync_started_at = Time.zone.now
        @log_counts_before = count_all
      end

      def stop
        @logger.info("Stopped count for: #{@context_string}")

        log_all(@log_counts_before, prefix: @prefix_for_counts_before)

        @log_counts_after = count_all
        log_all(@log_counts_after, prefix: @prefix_for_counts_after)

        @log_counts_diff = calculate_difference
        log_all(@log_counts_diff, prefix: @prefix_for_counts_diff)

        @log_updated_during = count_updated
        log_all(@log_updated_during, prefix: @prefix_for_updated_during)
      end

      def calculate_difference
        raise "No counts before, run start" if @log_counts_before.blank?
        raise "No counts after, run stop" if @log_counts_after.blank?

        @log_counts_diff = @log_counts_after.to_h do |key, new_value|
          [key, new_value - @log_counts_before[key]]
        end
      end

      private

      def log_all(counts, prefix:)
        counts.each_key do |key|
          @logger.info("#{prefix}: #{key}: #{counts[key]}")
        end
      end

      def paper_trail_version_key
        return "paper_trail_versions" if @user_id_to_limit_versions_to.present?

        "paper_trail_versions_for_user_#{@user_id_to_limit_versions_to}"
      end

      def paper_trail_version_count
        return PaperTrail::Version.count if @user_id_to_limit_versions_to.present?

        PaperTrail::Version.where(whodunnit: @user_id_to_limit_versions_to).count
      end

      def count_updated # rubocop:disable Metrics/AbcSize
        raise "Need to set @sync_started_at first" if @sync_started_at.blank?

        {
          sync_status_attempts: SyncStatus.where(last_attempted_sync_at: @sync_started_at..).count,
          sync_statuses_updated_to_success:
            SyncStatus.where(last_successful_sync_at: @sync_started_at..).count,
          sync_statuses_updated_to_failure:
            SyncStatus.where(last_attempted_sync_at: @sync_started_at..)
                      .where(last_successful_sync_at: nil).count,
          spaces_updated: Space.where(updated_at: @sync_started_at..).count,
          space_types_updated: SpaceType.where(updated_at: @sync_started_at..).count,
          space_groups_updated: SpaceGroup.where(updated_at: @sync_started_at..).count,
          space_contacts_updated: SpaceContact.where(updated_at: @sync_started_at..).count,
          facilities_updated: Facility.where(updated_at: @sync_started_at..).count,
          space_facilities_updated: SpaceFacility.where(updated_at: @sync_started_at..).count,
          reviews_updated: Review.where(updated_at: @sync_started_at..).count,
          facility_reviews_updated: FacilityReview.where(updated_at: @sync_started_at..).count
        }
      end

      def count_all
        {
          sync_statuses_total: SyncStatus.count,
          successful_sync_statuses: SyncStatus.where.not(last_successful_sync_at: nil).count,
          failed_sync_statuses: SyncStatus.where(last_successful_sync_at: nil).count,
          spaces: Space.count,
          space_types: SpaceType.count,
          space_groups: SpaceGroup.count,
          space_contacts: SpaceContact.count,
          facilities: Facility.count,
          space_facilities: SpaceFacility.count,
          reviews: Review.count,
          facility_reviews: FacilityReview.count,
          paper_trail_version_key => paper_trail_version_count
        }
      end
    end
  end
end
