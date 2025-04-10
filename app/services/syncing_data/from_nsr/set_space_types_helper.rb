# frozen_string_literal: true

module SyncingData
  module FromNsr
    module SetSpaceTypesHelper
      private

      def set_space_types(space, school_data)
        school_category_titles = school_data["Skolekategorier"].pluck("Navn")
        space_types = filter_out_old_space_types_for_schools(space.space_types)

        space_types << SpaceType.find_by!(type_name: "Grunnskole") if school_category_titles.include?("Grunnskole")

        space_types << SpaceType.find_by!(type_name: "VGS") if school_category_titles.include?("Videregående skole")

        if school_category_titles.include?("Folkehøyskole")
          space_types << SpaceType.find_by!(type_name: "Folkehøgskole")
        end

        raise "No space type found for school" if space_types.blank?

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
    end
  end
end
