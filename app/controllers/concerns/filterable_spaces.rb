# frozen_string_literal: true

module FilterableSpaces # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  private

  def set_filterable_facility_categories
    @filterable_facility_categories = FacilityCategory.includes(:facilities).all
  end

  def set_filterable_space_types
    @filterable_space_types = SpaceType.all
  end

  def set_filtered_facilities
    facility_ids = sanitize_id_list(params[:facilities])
    @filtered_facilities = Facility.includes(:facility_categories).find(facility_ids)
  end

  def set_filtered_geo_area_ids
    unless params[:fylker].present? || params[:kommuner].present?
      return @filtered_fylke_ids, @filtered_kommune_ids, @filtered_geo_area_ids = []
    end

    kommune_ids = sanitize_id_list(params[:kommuner])
    fylke_ids = fylke_ids_excluding_those_with_a_selected_kommune(sanitize_id_list(params[:fylker]), kommune_ids)

    @filtered_fylke_ids = fylke_ids
    @filtered_kommune_ids = kommune_ids
    @filtered_geo_area_ids = [*fylke_ids, *kommune_ids]
  end

  def fylke_ids_excluding_those_with_a_selected_kommune(unfiltered_fylke_ids, kommune_ids)
    return unfiltered_fylke_ids if kommune_ids.blank?

    fylker_for_selected_kommuner = Kommune.where(id: kommune_ids).pluck(:parent_id).uniq

    unfiltered_fylke_ids.reject do |fylke_id|
      fylker_for_selected_kommuner.include?(fylke_id)
    end
  end

  def filter_spaces
    set_filters_from_session_or_params
    set_filterable_facility_categories
    set_filterable_space_types
    set_filtered_facilities

    @filtered_spaces = Space.all
    @filtered_spaces = filter_by_fylker_and_kommuner
    @filtered_spaces = filter_by_map_bounds
    @filtered_spaces = filter_by_title
    @filtered_spaces = filter_by_space_types
    @filtered_spaces = filter_and_order_by_facilities

    store_filters_in_session
  end

  def filter_spaces_for_vector_tiles
    set_filters_from_session_or_params

    @filtered_spaces = Space.all
    @filtered_spaces = filter_by_fylker_and_kommuner
    @filtered_spaces = filter_by_title
    @filtered_spaces = filter_by_space_types
    @filtered_spaces = filter_and_order_by_facilities
  end

  def filter_by_title
    return @filtered_spaces if params[:search_for_title].blank?

    @search_by_title = params[:search_for_title]
    @filtered_spaces.filter_on_title(@search_by_title)
  end

  def filter_by_space_types
    return @filtered_spaces if params[:space_types].blank?

    space_types = params[:space_types]&.map(&:to_i)
    @filtered_space_types = SpaceType.find(space_types)
    @filtered_spaces.filter_on_space_types(space_types)
  end

  def fylke_or_kommune_params_present?
    params[:fylker].present? || params[:kommuner].present?
  end

  def map_bounding_box_params_present?
    params[:north_west_lat].present? && params[:north_west_lng].present? &&
      params[:south_east_lat].present? && params[:south_east_lng].present?
  end

  def filter_by_fylker_and_kommuner
    return @filtered_spaces unless fylke_or_kommune_params_present?

    set_filtered_geo_area_ids

    @filtered_spaces
      .filter_on_fylker_or_kommuner(
        fylke_ids: @filtered_fylke_ids,
        kommune_ids: @filtered_kommune_ids
      )
  end

  def filter_by_map_bounds
    return @filtered_spaces unless map_bounding_box_params_present?

    @filtered_spaces.filter_on_map_bounds(
      params[:north_west_lat].to_f,
      params[:north_west_lng].to_f,
      params[:south_east_lat].to_f,
      params[:south_east_lng].to_f
    )
  end

  def sanitize_id_list(array_of_ids)
    return [] if array_of_ids.blank?

    array_of_ids.uniq.select { |id| id.to_i.to_s == id }.map(&:to_i)
  end

  def filter_and_order_by_facilities
    sanitized_facility_list = sanitize_id_list(params[:facilities])
    return @filtered_spaces.order_by_star_rating if sanitized_facility_list.blank?

    @filtered_spaces.filter_and_order_by_facilities(sanitized_facility_list)
  end

  def any_filters_set?
    filter_keys.detect { |key| params[key] }
  end

  def any_filters_stored_in_session?
    session[:last_filter_params].present? &&
      filter_keys.any? { |key| session[:last_filter_params][key].present? }
  end

  def store_filters_in_session
    session[:last_filter_params] = params_from_search
  end

  def filter_keys
    %w[
      search_for_title
      north_west_lat
      north_west_lng
      south_east_lat
      south_east_lng
    ]
  end

  def filter_array_keys
    {
      facilities: [],
      space_types: [],
      fylker: [],
      kommuner: []
    }
  end

  def set_filters_from_session_or_params
    return params_from_search if any_filters_set?
    return params_from_session if any_filters_stored_in_session?

    set_permitted_params
  end

  def params_from_session
    filter_keys.each do |key|
      params[key] = session[:last_filter_params][key]
    end
    set_permitted_params
  end

  def params_from_search
    set_permitted_params
  end

  def set_permitted_params
    remove_duplicate_params
    params.permit(*filter_keys, *filter_array_keys)
  end

  def remove_duplicate_params
    # When a facility is in multiple facility categories, they are marked as duplicates
    # using JS, by changing the name and id to start with 'duplicate_'.
    # Here we filter them out as we don't need them in the back end:
    params.delete_if { |key, _| key.to_s.start_with?("duplicate_") }
  end
end
