# frozen_string_literal: true

module SyncingData
  module FromNsr
    module FetchSchoolsHelper # rubocop:disable Metrics/ModuleLength
      include CacheHelper

      SCHOOL_CATEGORIES_TO_FETCH = {
        1 => "Grunnskole",
        2 => "Videregående skole",
        11 => "Folkehøyskole"
      }.freeze

      private

      def fetch_all_schools_and_data
        all_schools = fetch_combined_list_of_schools
        filtered_schools = select_relevant_schools_from_list(all_schools)

        fetch_details_about_all_schools(filtered_schools)
      end

      def fetch_combined_list_of_schools
        SCHOOL_CATEGORIES_TO_FETCH.keys.flat_map do |category_id|
          fetch_list_of_schools_for_category(category_id)
        end
      end

      def select_relevant_schools_from_list(schools)
        schools.select do |school|
          next false if school.blank?
          next true if school_is_active?(school)
          next true if school_in_database_and_should_be_synced?(school)

          false
        end
      end

      def school_is_active?(school)
        school["ErAktiv"] == true
      end

      def school_in_database_and_should_be_synced?(school)
        return false if school["Organisasjonsnummer"].blank?

        space = school_already_in_database(school)
        return false unless space

        sync_status = Admin::SyncStatus.for(id_from_source: space.organization_number, source: "nsr")
        return true if no_data_on_last_successful_sync?(sync_status)

        sync_status.last_successful_sync_at < Time.zone.parse(school["DatoEndret"])
      end

      def no_data_on_last_successful_sync?(sync_status)
        sync_status.last_successful_sync_at.blank?
      end

      def school_already_in_database(school)
        return false if school["Organisasjonsnummer"].blank?

        Space.find_by(organization_number: school["Organisasjonsnummer"])
      end

      def fetch_list_of_schools_for_category(category_id)
        url = "#{FromNsr::NSR_BASE_URL}/enheter/skolekategori/#{category_id}"

        logger.debug { "Fetching schools from NSR at url: #{url}" }
        begin
          response = HTTP.get(url)

          if response.status.success?
            # Parse the JSON correctly from the body
            parsed_json = JSON.parse(response.body.to_s)
            # Return the list of schools or an empty array if EnhetListe is missing
            schools = parsed_json["EnhetListe"] || []
            logger.debug { "Fetched #{schools.size} schools from url: #{url}" }

            schools
          else
            error_msg = "Failed to fetch schools from NSR API for category #{category_id}: #{response.status}"
            logger.error(error_msg)
            []
          end
        rescue StandardError => e
          logger.error("Error when fetching schools from NSR API for category #{category_id}: #{e.message}")
          []
        end
      end

      def fetch_details_about_all_schools(schools) # rubocop:disable Metrics/AbcSize
        failures = []

        logger.debug { "Fetching details from NSR about #{schools.size} schools" }

        schools_with_details = schools.map.with_index do |school, index|
          org_number = school["Organisasjonsnummer"]
          next if org_number.blank?

          logger.debug do
            "Fetch details for school ##{index + 1} / #{schools.size}, based on org_number: #{org_number}"
          end

          begin
            details_about_school(
              org_number: org_number,
              date_changed_at_from_nsr: school["DatoEndret"]
            )
          rescue StandardError => e
            # Add to failures list but continue processing other schools
            failures << { org_number: org_number, error: e.message }
            logger.error("Error fetching details for school #{org_number}: #{e.message}")
          end
        end.compact_blank

        logger.error("Failed to fetch details for #{failures.size} schools") if failures.any?

        schools_with_details
      end

      def details_about_school(org_number:, date_changed_at_from_nsr:)
        # Try to get from cache first
        cache_key = "nsr:school:#{org_number}"
        cached_data = Rails.cache.read(cache_key)

        return serve_cached_data(cache_key, cached_data) if cache_still_fresh?(cached_data:, date_changed_at_from_nsr:)

        fetch_and_cache_details_about_school(org_number, cache_key)
      end

      def fetch_and_cache_details_about_school(org_number, cache_key)
        url = "#{FromNsr::NSR_BASE_URL}/enhet/#{org_number}"
        logger.debug { "Fetching school details about #{org_number} from NSR at url: #{url}" }

        begin
          response = HTTP.get(url)
          cache_and_return_school_details(response, org_number, cache_key)
        rescue StandardError => e
          error_msg = "Error fetching school details for org number #{org_number}: #{e.message}"
          logger.error(error_msg)
          raise
        end
      end

      def cache_and_return_school_details(response, org_number, cache_key)
        if response.status.success?
          data = JSON.parse(response.body.to_s)
          cache_school_details(cache_key, data)
          data
        else
          error_msg = "Failed to fetch school details from NSR API for org number #{org_number}: #{response.status}"
          raise "API Error: #{error_msg}"
        end
      end
    end
  end
end
