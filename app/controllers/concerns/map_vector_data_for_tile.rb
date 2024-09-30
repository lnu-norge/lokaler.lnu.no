# frozen_string_literal: true

module MapVectorDataForTile
  extend ActiveSupport::Concern

  def show
    mvt_data = mvt_data_to_use
    return head :no_content if mvt_data.blank?

    send_data mvt_data, disposition: "inline", type: "application/vnd.mapbox-vector-tile"
  rescue StandardError => e
    error = "Error generating tile z:#{@tile_coordinates[:z]}, x:#{@tile_coordinates[:x]}, y:#{@tile_coordinates[:y]}"
    message = "#{e.message}\n#{e.backtrace&.join("\n")}"
    Rails.logger.error("#{error}: #{message}")
    head :internal_server_error
  end

  private

  def mvt_data_to_use
    # Override this with cached_mvt_data_for_tile when you want caching
    mvt_data_for_tile
  end

  def define_tile_coordinates
    @tile_coordinates = {
      z: params[:z].to_i,
      x: params[:x].to_i,
      y: params[:y].to_i
    }
  end

  def mvt_data_for_tile
    # First row has our MVT file:
    first_row_of_result = ActiveRecord::Base.connection.exec_query(
      vector_tile_query,
      "vector_sql_query",
      [
        @tile_coordinates[:z],
        @tile_coordinates[:x],
        @tile_coordinates[:y]
      ]
    ).first

    # We need to unescape it to get the raw binary MVT data.
    # There should be a better way to not escape it in the first place.
    ActiveRecord::Base.connection.unescape_bytea(first_row_of_result["mvt"])
  end

  def cached_mvt_data_for_tile(cache_key_prefix: "", cache_options: {})
    Rails.cache.fetch("#{cache_key_prefix}#{mvt_data_cache_key}", *cache_options) do
      mvt_data_for_tile
    end
  end

  def mvt_data_cache_key
    params_for_key = params.permit(:z, :x, :y, q: {}).to_h
    "vector_tile/#{params_for_key.to_param}"
  end

  def vector_tile_query
    raise "You need to define a vector_tile_query SQL query for your MVT data"
  end
end
