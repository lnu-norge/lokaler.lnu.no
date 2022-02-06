# frozen_string_literal: true

require "http"

module Spaces
  class LocationSearchService < ApplicationService
    URL = "https://ws.geonorge.no/adresser/v1/sok?"

    def initialize(address: nil, post_number: nil)
      @address = address
      @post_number = post_number

      super()
    end

    def build_url
      url =
        [
          URL,
          "utkoordsys=4258&",
          "treffPerSide=10&",
          "side=0&",
          "asciiKompatibel=true"
        ].join

      url += "&sok=#{address}" if address.present?
      url += "&postnummer=#{post_number}" if post_number.present?
      url
    end

    def call
      result = JSON.parse(HTTP.get(build_url).body)

      return [] if result["adresser"].nil?

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

    private

    attr_reader :address, :post_number, :post_address
  end
end
