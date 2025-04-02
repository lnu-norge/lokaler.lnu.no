# frozen_string_literal: true

module SyncingData
  module FromNsr
    class SyncService < ApplicationService
      NSR_BASE_URL = "https://data-nsr.udir.no/v4"
      SCHOOL_CATEGORIES = {
        1 => "Grunnskole",
        2 => "Videregående skole",
        11 => "Folkehøyskole"
      }.freeze

      def call
        all_schools = fetch_all_schools
        filtered_schools = filter_schools(all_schools)
        process_list_of_schools(filtered_schools)
      end

      private

      def fetch_all_schools
        SCHOOL_CATEGORIES.keys.flat_map do |category_id|
          fetch_schools_for_category(category_id)
        end
      end

      def filter_schools(schools)
        # Return empty array if schools is nil
        return [] unless schools.is_a?(Array)

        schools.select do |school|
          # Skip nil schools
          next false if school.nil?

          # Keep if school is active
          next true if school["ErAktiv"] == true

          # For inactive schools, keep only if we have a space with matching org number
          if school["OrgNr"].present?
            Space.exists?(organization_number: school["OrgNr"])
          else
            false # Filter out inactive schools with no org number
          end
        end
      end

      def fetch_schools_for_category(category_id)
        url = "#{NSR_BASE_URL}/enheter/skolekategori/#{category_id}"

        begin
          response = HTTP.get(url)

          if response.status.success?
            # Parse the JSON correctly from the body
            parsed_json = JSON.parse(response.body.to_s)
            # Return the list of schools or an empty array if EnhetListe is missing
            parsed_json["EnhetListe"] || []
          else
            error_msg = "Failed to fetch schools from NSR API for category #{category_id}: #{response.status}"
            Rails.logger.error(error_msg)
            []
          end
        rescue StandardError => e
          Rails.logger.error("Error when fetching schools from NSR API for category #{category_id}: #{e.message}")
          []
        end
      end

      def process_list_of_schools(all_schools)
        # TODO: Implement processing logic for the fetched schools data
        # This would create/update Space and SpaceGroup records as needed
      end
    end
  end
end
