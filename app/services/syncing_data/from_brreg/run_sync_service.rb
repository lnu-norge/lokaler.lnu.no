# frozen_string_literal: true

module SyncingData
  module FromBrreg
    BRREG_BASE_URL = "https://data.brreg.no/enhetsregisteret/api"
    class RunSyncService < ApplicationService
      include TaggedLogHelper

      def initialize
        @count_logger = count_logger

        super
      end

      def call
        @count_logger.start
        sync_spaces
        @count_logger.stop
      end

      private

      def count_logger
        @count_logger ||= SyncingData::Shared::CountLogger.new(
          name: "BRREG sync",
          limit_versions_to_user_id: Robot.brreg.id,
          logger: rails_logger_with_tags
        )
      end

      def sync_spaces
        spaces_with_organization_numbers.each do |space|
          sync_space(space)
        end
      end

      def sync_space(space)
        logger.debug { "Syncing space #{space.id}" }

        contact_information_from_brreg_for(org_number: space.organization_number)
      end

      def contact_information_from_brreg_for(org_number:)
        raw_contact_information_from_brreg_for(org_number: org_number)
      end

      def raw_contact_information_from_brreg_for(org_number:)
        data = brreg_data_for(org_number: org_number)

        {
          email: data["epostadresse"],
          phone: data["telefon"],
          mobile: data["mobil"],
          website: data["hjemmeside"]
        }
      end

      def brreg_data_for(org_number:)
        logger.debug { "Fetching data from BRREG for org_number: #{org_number}" }

        begin
          data = data_from_brreg_for(org_number:)
          return data if data.present?

          logger.debug { "No data found for org number #{org_number}" }
          {}
        rescue StandardError => e
          logger.error("Error when fetching data from BRREG API for org number #{org_number}: #{e.message}")
          {}
        end
      end

      def data_from_brreg_for(org_number:)
        # First attempt /enhter/ end point
        url = "#{BRREG_BASE_URL}/enheter/#{org_number}"

        response = HTTP.get(url)

        if response.status.success?
          JSON.parse(response.body.to_s)
        elsif response.status.code == 404
          # If 404, it might be on underenhet end point:
          then_underenhet_data_from_brreg_for(org_number:)
        else
          raise "Failed to fetch data from BRREG enheter API for org number #{org_number}: #{response.status}"
        end
      end

      def then_underenhet_data_from_brreg_for(org_number:)
        url = "#{BRREG_BASE_URL}/underenheter/#{org_number}"

        response = HTTP.get(url)

        if response.status.success?
          JSON.parse(response.body.to_s)
        elsif response.status.code == 404
          logger.debug { "No data found for org number in either underenhet or enhet for #{org_number}" }

          nil
        else
          raise "Failed to fetch data from underenhet BRREG API for org number #{org_number}: #{response.status}"
        end
      end

      def spaces_with_organization_numbers
        Space.where.not(organization_number: nil)
      end
    end
  end
end
