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
        process_list_of_schools(all_schools)
      end

      private

      def fetch_all_schools
        SCHOOL_CATEGORIES.keys.flat_map do |category_id|
          fetch_schools_for_category(category_id)
        end
      end

      def fetch_schools_for_category(category_id)
        url = "#{NSR_BASE_URL}/enheter/skolekategori/#{category_id}"

        begin
          response = HTTP.get(url)

          if response.status.success?
            json = response.body.to_json
            json["EnhetListe"]
          else
            error_msg = "Failed to fetch schools from NSR API for category #{category_id}: #{response.status}"
            Rails.logger.error(error_msg)
            []
          end
        rescue HTTP::Error => e
          Rails.logger.error("HTTP error when fetching schools from NSR API for category #{category_id}: #{e.message}")
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
