# frozen_string_literal: true

module SyncingData
  module FromNsr
    module SetLocationHelper
      private

      def set_location(space, school_data)
        safely_update_field(space, :address, school_data["Beliggenhetsadresse"]["Adresse"])
        safely_update_field(space, :post_number, school_data["Beliggenhetsadresse"]["Postnummer"])
        safely_update_field(space, :post_address, school_data["Beliggenhetsadresse"]["Poststed"])
        set_lat_lng(space, school_data)
      end

      def set_lat_lng(space, school_data)
        latitude = school_data["Koordinat"]["Breddegrad"]
        longitude = school_data["Koordinat"]["Lengdegrad"]
        nsr_has_lat_lng = latitude.present? && longitude.present? && latitude != 0 && longitude != 0

        unless nsr_has_lat_lng
          # If lat lon is not set from NSR, then we have to set it ourselves:
          geonorge_geo_data = get_lat_lng_from_geonorge(space)
          if geonorge_geo_data.nil?
            throw "School has no lat/lng in NSR or GeoNorge. Org nr: #{space.organization_number}"
          end

          return space.update(lat: geonorge_geo_data[:lat], lng: geonorge_geo_data[:lng])
        end

        space.update(lat: latitude, lng: longitude)
      end

      def get_lat_lng_from_geonorge(space)
        get_lat_lng_based_on_address(space.address, space.post_number)
      end

      def get_lat_lng_based_on_address(address, post_number)
        results = Spaces::LocationSearchService.call(
          address:,
          post_number:,
          attempt_preceding_addresses: true
        )
        return nil if results.empty?

        results.first
      end
    end
  end
end
