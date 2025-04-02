# frozen_string_literal: true

require_relative "nsr_cache_helper"

module SyncingData
  module FromNsr
    class SyncService < ApplicationService
      include NsrCacheHelper
      NSR_BASE_URL = "https://data-nsr.udir.no/v4"
      SCHOOL_CATEGORIES = {
        1 => "Grunnskole",
        2 => "Videregående skole",
        11 => "Folkehøyskole"
      }.freeze

      def call
        all_schools = fetch_all_schools
        filtered_schools = filter_schools(all_schools)
        schools_with_details = fetch_all_school_details(filtered_schools)
        process_list_of_schools(schools_with_details)
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

      def fetch_school_details(org_number:, date_changed_at_from_nsr:)
        # Try to get from cache first
        cache_key = "nsr:school:#{org_number}"
        cached_data = Rails.cache.read(cache_key)

        return serve_cached_data(cache_key, cached_data) if cache_still_fresh?(cached_data:, date_changed_at_from_nsr:)

        fetch_and_cache_school_details(org_number, cache_key)
      end

      def fetch_and_cache_school_details(org_number, cache_key)
        url = "#{NSR_BASE_URL}/enhet/#{org_number}"

        begin
          response = HTTP.get(url)
          handle_school_details_response(response, org_number, cache_key)
        rescue StandardError => e
          error_msg = "Error fetching school details for org number #{org_number}: #{e.message}"
          Rails.logger.error(error_msg)
          raise
        end
      end

      def handle_school_details_response(response, org_number, cache_key)
        if response.status.success?
          data = JSON.parse(response.body.to_s)
          cache_school_details(cache_key, data)
          data
        else
          error_msg = "Failed to fetch school details from NSR API for org number #{org_number}: #{response.status}"
          raise "API Error: #{error_msg}"
        end
      end

      def fetch_all_school_details(schools)
        result = {}
        failures = []

        schools.each do |school|
          org_number = school["OrgNr"]
          next if org_number.blank?

          begin
            # Pass the DatoEndret from the list to avoid refetching the list
            details = fetch_school_details(org_number: org_number, date_changed_at_from_nsr: school["DatoEndret"])
            result[org_number] = details if details.present?
          rescue StandardError => e
            # Add to failures list but continue processing other schools
            failures << { org_number: org_number, error: e.message }
            Rails.logger.error("Error fetching details for school #{org_number}: #{e.message}")
          end
        end

        # Log a summary of failures
        if failures.any?
          Rails.logger.error("Failed to fetch details for #{failures.size} schools")
          # Optionally raise an error with the failure summary
          # raise "Failed to fetch details for #{failures.size} schools. See logs for details."
        end

        result
      end

      def process_list_of_schools(schools_with_details)
        # TODO: Implement processing logic for the fetched schools data
        # This would create/update Space and SpaceGroup records as needed
      end
    end
  end
end
