# frozen_string_literal: true

require "http"

module Spaces
  class LocationSearchService < ApplicationService
    URL = "https://ws.geonorge.no/adresser/v1/sok?"

    def initialize(address: nil, post_number: nil, attempt_preceding_addresses: false)
      @address = address
      @post_number = post_number
      @attempt_preceding_addresses = attempt_preceding_addresses

      super()
    end

    def call
      return fetch_preceding_addresses_until_one_is_not_found if @attempt_preceding_addresses
      return fetch_range_until_one_is_found if address_ends_in_range?

      fetch_addresses
    end

    private

    def build_url
      search_params = {
        utkoordsys: 4258,
        treffPerSide: 10,
        side: 0,
        asciiKompatibel: true
      }

      search_params[:sok] = @address if @address.present?
      search_params[:postnummer] = @post_number if @post_number.present?

      URL + search_params.to_query
    end

    def fetch_addresses
      result = JSON.parse(HTTP.get(build_url).body)

      return [] if result["adresser"].blank?

      result["adresser"].map do |address|
        point = address["representasjonspunkt"]
        {
          lat: point["lat"],
          lng: point["lon"],
          address: address["adressetekst"],
          post_number: address["postnummer"],
          post_address: address["poststed"],
          municipality_code: address["kommunenummer"]
        }
      end
    end

    def range_at_end_regex
      /(\d+)-(\d+)$/
    end

    def address_range
      @address&.match(range_at_end_regex)
    end

    def start_of_range
      address_range[1]
    end

    def end_of_range
      address_range[2]
    end

    def address_ends_in_range?
      address_range.present?
    end

    def addresses_from_range
      (start_of_range..end_of_range).map do |number|
        @address.gsub(range_at_end_regex, number)
      end
    end

    def fetch_range_until_one_is_found
      # Sometimes the address is given as a range, like this: "Fiktivgata 1-3"
      # We then have to look up each number separately, to see if any of them exist.
      # (Sometimes the first exists, sometimes the second, sometimes one in the middle)

      addresses_from_range.each do |address|
        @address = address
        result = fetch_addresses

        return result if result.present?
      end

      []
    end

    def street_number_from_address
      end_of_range if address_ends_in_range?

      @address.match(/(\d+)$/)[1]
    end

    def street_name_from_address
      @address.gsub(/(\d+)$/, "")
    end

    def last_preceding_addresses
      return [@address] if street_number_from_address.blank?

      all_previous_on_same_street = (1..street_number_from_address.to_i).to_a.map do |number|
        "#{street_name_from_address} #{number}"
      end

      # Sometimes the range is so large that we want to check the start of the range too
      all_previous_on_same_street << start_of_range if address_ends_in_range?

      all_previous_on_same_street.uniq.last(50).reverse
    end

    def fetch_preceding_addresses_until_one_is_not_found
      # First try the original address
      result = fetch_addresses
      return result if result.present?

      # Calculate the preceding addresses before altering @address
      preceding_addresses = last_preceding_addresses

      # Then try to see if the street exists at all
      @address = street_name_from_address
      result = fetch_addresses
      return [] if result.blank?

      # Then try the preceding addresses to see if any of them might work
      preceding_addresses.each do |address|
        @address = address
        result = fetch_addresses
        return result if result.present?
      end

      [] # Blank if nothing works
    end
  end
end
