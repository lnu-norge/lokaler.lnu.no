# frozen_string_literal: true

module SyncingData
  module FromNsr
    module NsrProcessSchoolsHelper
      private

      def process_list_of_schools(schools)
        schools.map do |school_data|
          Space.find_or_initialize_by(
            organization_number: school_data["OrgNr"]
          )
        end
      end
    end
  end
end
