# frozen_string_literal: true

module Spaces
  class MapSelectedGeoAreaController < ApplicationController
    include FilterableSpaces
    def show
      set_filters_from_session_or_params
      set_filtered_geo_area_ids

      geo_areas = GeographicalArea.where(id: @filtered_geo_area_ids)

      geojson_features = geo_areas.map do |geo_area|
        {
          type: "Feature",
          geometry: RGeo::GeoJSON.encode(geo_area.geo_area),
          properties: {
            id: geo_area.id,
            name: geo_area.name
          }
        }
      end

      geojson = {
        type: "FeatureCollection",
        features: geojson_features
      }

      render json: geojson
    end
  end
end
