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
    facility_ids = sanitize_facility_list(params[:facilities])
    @filtered_facilities = Facility.includes(:facility_categories).find(facility_ids)
  end

  def filter_spaces
    set_filters_from_session_or_params

    @filtered_spaces = Space.all

    set_filterable_facility_categories
    set_filterable_space_types
    set_filtered_facilities

    filter_by_location
    filter_by_title
    filter_by_space_types
    filter_and_order_by_facilities

    store_filters_in_session
  end

  def filter_spaces_for_vector_tiles
    set_filters_from_session_or_params

    @filtered_spaces = spaces_from_facilities
    filter_by_title
    filter_by_space_types
  end

  def filter_by_title
    return if params[:search_for_title].blank?

    @search_by_title = params[:search_for_title]
    @filtered_spaces = @filtered_spaces.filter_on_title(@search_by_title)
  end

  def filter_by_space_types
    return if params[:space_types].blank?

    space_types = params[:space_types]&.map(&:to_i)
    @filtered_space_types = SpaceType.find(space_types)
    @filtered_spaces = @filtered_spaces.filter_on_space_types(space_types)
  end

  def location_params_present?
    params[:north_west_lat].present? && params[:north_west_lng].present? &&
      params[:south_east_lat].present? && params[:south_east_lng].present?
  end

  def filter_by_location
    return unless location_params_present?

    @filtered_spaces = @filtered_spaces.filter_on_location(
      params[:north_west_lat].to_f,
      params[:north_west_lng].to_f,
      params[:south_east_lat].to_f,
      params[:south_east_lng].to_f
    )
  end

  def sanitize_facility_list(array_of_facility_ids)
    return [] if array_of_facility_ids.blank?

    array_of_facility_ids.uniq.select { |id| id.to_i.to_s == id }.map(&:to_i)
  end

  def filter_and_order_by_facilities
    sanitized_facility_list = sanitize_facility_list(params[:facilities])
    return @filtered_spaces = @filtered_spaces.order_by_star_rating if sanitized_facility_list.blank?

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
      facilities
      space_types
      search_for_title
      north_west_lat
      north_west_lng
      south_east_lat
      south_east_lng
    ]
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
    params.permit(*filter_keys, facilities: [], space_types: [])
  end

  def remove_duplicate_params
    # When a facility is in multiple facility categories, they are marked as duplicates
    # using JS, by changing the name and id to start with 'duplicate_'.
    # Here we filter them out as we don't need them in the back end:
    params.delete_if { |key, _| key.to_s.start_with?("duplicate_") }
  end
end
