# frozen_string_literal: true

module FilterableSpaces
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
    @spaces = spaces_from_facilities

    set_filterable_facility_categories
    set_filterable_space_types
    set_filtered_facilities

    filter_by_location
    filter_by_title
    filter_by_space_types
  end

  def filter_by_title
    return if params[:search_for_title].blank?

    @spaces = @spaces.filter_on_title(params[:search_for_title])
  end

  def filter_by_space_types
    return if params[:space_types].blank?

    space_types = params[:space_types]&.map(&:to_i)
    @spaces = @spaces.filter_on_space_types(space_types)
  end

  def location_params_present?
    params[:north_west_lat].present? && params[:north_west_lng].present? &&
      params[:south_east_lat].present? && params[:south_east_lng].present?
  end

  def filter_by_location
    return unless location_params_present?

    @spaces = @spaces.filter_on_location(
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

  def spaces_from_facilities
    sanitized_facility_list = sanitize_facility_list(params[:facilities])
    return Space.order_by_star_rating if sanitized_facility_list.blank?

    Space.filter_and_order_by_facilities(sanitized_facility_list)
  end
end
