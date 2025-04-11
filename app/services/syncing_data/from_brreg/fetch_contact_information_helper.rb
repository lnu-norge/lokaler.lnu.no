# frozen_string_literal: true

module SyncingData
  module FromBrreg
    module FetchContactInformationHelper
      private

      def contact_information_from_brreg_for(org_number:)
        raw_data = raw_contact_information_from_brreg_for(org_number: org_number)

        {
          email: parse_email(raw_data[:email]),
          phone: parse_phone(raw_data[:phone]),
          mobile: parse_phone(raw_data[:mobile]),
          website: parse_url(raw_data[:website])
        }
      end

      def parse_email(email)
        return nil if email.blank?

        email_stripped_of_spaces = email.strip.gsub(/\s+/, "")

        valid_email_regex = /\A[^@\s]+@[^@\s]+\z/
        return nil unless valid_email_regex.match?(email_stripped_of_spaces)

        email_stripped_of_spaces
      end

      def parse_phone(phone)
        return nil if phone.blank?

        phone.strip.gsub(/\s+/, "")
      end

      def parse_url(url)
        return nil if url.blank?

        url_with_no_spaces_at_start_or_end = url.strip

        uri = Addressable::URI.parse(url_with_no_spaces_at_start_or_end)
        return nil if uri.blank?
        return uri.to_s if uri.scheme # Has http or https

        "http://#{url_with_no_spaces_at_start_or_end}"
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
    end
  end
end
