# frozen_string_literal: true

module Spaces
  class MapVectorController < ApplicationController
    include MapVectorDataForTile
    include FilterableSpaces
    before_action :set_permitted_params, :define_tile_coordinates

    private

    VECTOR_TILE_CACHE_KEY_PREFIX = "spaces_vector_tile/"

    #  TODO: Re-enable caching once I understand how it works on Heroku
    #  def mvt_data_to_use
    #    cached_mvt_data_for_tile(cache_key_prefix: VECTOR_TILE_CACHE_KEY_PREFIX)
    #    # This cache never expires. To clear it, do
    #    # Rails.cache.delete_matched("spaces_vector_tile/*")
    #  end

    def pre_filter_spaces_subquery
      filter_spaces_for_vector_tiles
      # SQL for getting all relevant canvassing_result IDs:
      @filtered_spaces.select(:id).to_sql
    end

    def set_permitted_params
      remove_duplicate_params
      params.permit([:z, :x, :y, *all_filters])
    end

    def vector_tile_query # rubocop:disable Metrics/MethodLength
      <<-SQL.squish
      WITH#{' '}
      bounds AS (
        SELECT ST_TileEnvelope($1, $2, $3) AS geom
      ),
      filtered_results AS (
        #{pre_filter_spaces_subquery}
      ),
      mvtgeom AS (
        SELECT#{' '}
          ST_AsMVTGeom(
            ST_Transform(space.geo_point::geometry, 3857),
            bounds.geom
          ) AS geom,
          space.id
        FROM#{' '}
          spaces space
        JOIN#{' '}
          bounds ON ST_Intersects(
            ST_Transform(space.geo_point::geometry, 3857),
            bounds.geom
          )#{' '}
        WHERE#{' '}
          space.geo_point IS NOT NULL
          AND space.id IN (SELECT id FROM filtered_results)
      )
      SELECT ST_AsMVT(mvtgeom.*, 'spaces', 4096, 'geom') AS mvt
      FROM mvtgeom;
      SQL
    end
  end
end
