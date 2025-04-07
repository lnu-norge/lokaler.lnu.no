# frozen_string_literal: true

module SyncingData
  module FromNsr
    module NsrProcessSchoolsHelper
      private

      def process_list_of_schools(schools)
        schools

        # schools.map do |school_data|
        #  find_existing_space(school_data)
        # end#
      end

      def find_existing_space(school_data)
        Space.find_by(organization_number: school_data["Organisasjonsnummer"])
      end
    end
  end
end
