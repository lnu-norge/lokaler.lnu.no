# frozen_string_literal: true

module FilterableByMapBounds
  extend ActiveSupport::Concern

  private

  def filter_by_map_bounds_turned_off?
    params[:filter_by_map_bounds] == "off"
  end

  def map_bounding_box_params_present?
    params[:north_west_lat].present? && params[:north_west_lng].present? &&
      params[:south_east_lat].present? && params[:south_east_lng].present?
  end

  def filter_by_map_bounds
    return @filtered_spaces if filter_by_map_bounds_turned_off?
    return @filtered_spaces unless map_bounding_box_params_present?

    @filtered_spaces.filter_on_map_bounds(
      params[:north_west_lat].to_f,
      params[:north_west_lng].to_f,
      params[:south_east_lat].to_f,
      params[:south_east_lng].to_f
    )
  end
end
