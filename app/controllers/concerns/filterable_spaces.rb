# frozen_string_literal: true

module FilterableSpaces
  extend ActiveSupport::Concern

  include FilterableByStoredFiltersOrParams
  include FilterableByTitle
  include FilterableByFacilities
  include FilterableByMapBounds
  include FilterableByFylkerAndKommuner
  include FilterableBySpaceTypes

  private

  def filter_spaces
    set_filters_from_session_or_params
    store_filters_in_session

    set_filterable_facility_categories
    set_filterable_space_types
    set_filtered_facilities

    @filtered_spaces = Space.all
    @filtered_spaces = filter_by_fylker_and_kommuner
    @filtered_spaces = filter_by_map_bounds
    @filtered_spaces = filter_by_title
    @filtered_spaces = filter_by_space_types
    @filtered_spaces = filter_and_order_by_facilities
  end

  def filter_spaces_for_vector_tiles
    set_filters_from_session_or_params

    @filtered_spaces = Space.all
    @filtered_spaces = filter_by_fylker_and_kommuner
    @filtered_spaces = filter_by_title
    @filtered_spaces = filter_by_space_types
    @filtered_spaces = filter_and_order_by_facilities
  end

  def singular_filters
    %w[
      filter_by_map_bounds
      search_for_title
      north_west_lat
      north_west_lng
      south_east_lat
      south_east_lng
    ]
  end

  def filter_arrays
    {
      facilities: [],
      space_types: [],
      fylker: [],
      kommuner: []
    }
  end

  def all_filters
    [
      *singular_filters,
      **filter_arrays
    ]
  end

  def all_filter_keys
    [
      *singular_filters,
      *filter_arrays.keys.map(&:to_s)
    ]
  end
end
