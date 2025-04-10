# frozen_string_literal: true

module SyncingData
  module FromNsr
    module ProcessSchoolsHelper
      include SetLocationHelper
      include SetSpaceGroupHelper
      include SetSpaceTypesHelper
      include LogSyncStatusHelper

      private

      def process_schools_and_save_space_data(schools)
        schools.filter_map do |school_data|
          next if school_data["Organisasjonsnummer"].blank?

          next unless school_changed_since_last_successful_sync(school_data)

          space = attempt_sync(school_data)
          next unless space

          space
        end
      end

      def attempt_sync(school_data)
        start_sync_log(school_data)

        raise_if_sync_is_not_possible(school_data)
        space = set_space_and_sync_data(school_data: school_data)
        log_successful_sync(school_data)

        space
      rescue StandardError => e
        log_failed_sync(school_data, e)

        nil
      end

      def raise_if_sync_is_not_possible(school_data)
        raise "This school is no longer active" if school_data["ErAktiv"] == false
        raise "This school is outside Norway" if school_is_outside_norway?(school_data)
      end

      def set_space_and_sync_data(school_data:)
        PaperTrail.request(whodunnit: Robot.nsr.id) do
          space = find_or_initialize_space(school_data)
          set_title(space, school_data)
          set_location(space, school_data)
          set_space_types(space, school_data)
          set_space_group(space, school_data)
          space.save! if space.changed?

          space
        end
      end

      def find_or_initialize_space(school_data)
        Space.find_or_initialize_by(organization_number: school_data["Organisasjonsnummer"])
      end

      def school_changed_since_last_successful_sync(school_data)
        school_data_changed_at = Time.zone.parse(school_data["DatoEndret"])
        return true if school_data_changed_at.blank?

        last_sync = SyncStatus.for(id_from_source: school_data["Organisasjonsnummer"], source: "nsr")
        return true if last_sync&.last_successful_sync_at.blank?

        school_data_changed_at > last_sync.last_successful_sync_at
      end

      def set_title(space, school_data)
        title = school_data["Navn"] || school_data["FulltNavn"]

        safely_update_field(space, :title, title)
      end

      def school_is_outside_norway?(school)
        school["Organisasjonsnummer"].match?(/U\d+/)
      end

      def safely_update_field(model, field, new_data)
        SyncingData::Shared::SafelySyncDataService.new(
          user_or_robot_doing_the_syncing: Robot.nsr,
          model: model,
          field: field,
          new_data: new_data
        ).safely_sync_data
      end
    end
  end
end
