# frozen_string_literal: true

module SyncingData
  module FromNsr
    module ProcessSchoolsHelper
      include SetLocationHelper
      include SetSpaceGroupHelper
      include LogSyncStatusHelper

      private

      def process_schools_and_save_space_data(schools)
        schools.filter_map do |school_data|
          next if school_data["Organisasjonsnummer"].blank?

          begin
            start_sync_log(school_data)

            raise "This school is no longer active" if school_data["ErAktiv"] == false

            space = find_or_initialize_space(school_data)
            set_title(space, school_data)
            set_location(space, school_data)
            set_space_types(space, school_data)
            set_space_group(space, school_data)
            space.save! if space.changed?

            log_successful_sync(school_data)

            space
          rescue StandardError => e
            log_failed_sync(school_data, e)
            nil
          end
        end
      end

      def find_or_initialize_space(school_data)
        Space.find_or_initialize_by(organization_number: school_data["Organisasjonsnummer"])
      end

      def set_title(space, school_data)
        title = school_data["Navn"] || school_data["FulltNavn"]

        safely_update_field(space, :title, title)
      end

      def set_space_types(space, school_data)
        school_category_titles = school_data["Skolekategorier"].pluck("Navn")
        space_types = filter_out_old_space_types_for_schools(space.space_types)

        space_types << SpaceType.find_by(type_name: "Grunnskole") if school_category_titles.include?("Grunnskole")

        space_types << SpaceType.find_by(type_name: "VGS") if school_category_titles.include?("Videregående skole")

        space_types << SpaceType.find_by(type_name: "Folkehøgskole") if school_category_titles.include?("Folkehøyskole")

        safely_update_field(space, :space_types, space_types.uniq.compact)
      end

      def filter_out_old_space_types_for_schools(space_types)
        return [] if space_types.blank?

        space_types.select do |space_type|
          # These were used in the original NSR sync, but give little value
          next false if space_type.type_name == "Barneskole"
          next false if space_type.type_name == "Ungdomsskole"

          true
        end
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
