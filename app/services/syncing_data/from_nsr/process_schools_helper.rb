# frozen_string_literal: true

module SyncingData
  module FromNsr
    module ProcessSchoolsHelper
      include SetLocationHelper
      include SetSpaceGroupHelper

      private

      def process_schools_and_save_space_data(schools)
        schools.map do |school_data|
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

      def set_title(space, school_data)
        title = school_data["Navn"] || school_data["FulltNavn"]

        safely_update_field(space, :title, title)
      end

      def set_space_types(space, school_data)
        school_category_titles = school_data["Skolekategorier"].pluck("Navn")
        space_types = space.space_types || []

        if school_category_titles.include?("Grunnskole")
          space_types << SpaceType.find_or_create_by(type_name: "Grunnskole")
        end

        if school_category_titles.include?("Videregående skole")
          space_types << SpaceType.find_or_create_by(type_name: "VGS")
        end

        if school_category_titles.include?("Folkehøyskole")
          space_types << SpaceType.find_or_create_by(type_name: "Folkehøgskole")
        end

        safely_update_field(space, :space_types, space_types.compact)
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
