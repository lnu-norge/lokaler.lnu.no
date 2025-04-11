# frozen_string_literal: true

module SyncingData
  module FromBrreg
    module FetchContactInformationHelper
      private

      def contact_information_from_brreg_for(org_number:)
        raw_data = raw_contact_information_from_brreg_for(org_number:)

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

        number = phone.strip.gsub(/\s+/, "")
        return nil unless validate_phone(number)

        number
      end

      def validate_phone(phone)
        PhoneValidationService.new(phone).valid_phone?
      end

      def parse_url(url)
        return nil if url.blank?

        url = url_with_scheme(url)
        return nil if url.blank?
        return nil unless validate_url(url)

        url
      end

      def url_with_scheme(url)
        url_with_no_spaces_at_start_or_end = url.strip
        uri = Addressable::URI.parse(url_with_no_spaces_at_start_or_end)
        return nil if uri.blank?
        return uri.to_s if uri.scheme # Has http or https

        "http://#{url_with_no_spaces_at_start_or_end}"
      rescue Addressable::URI::InvalidURIError
        nil
      end

      def validate_url(url)
        UrlValidationService.new(url).valid_url?
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

        data = data_from_brreg_for(org_number:)
        return data if data.present?

        logger.debug { "No data found for org number #{org_number}" }
        raise "No data in BRREG"
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
