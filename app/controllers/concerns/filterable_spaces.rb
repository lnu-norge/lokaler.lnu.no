# frozen_string_literal: true

module FilterableSpaces
  private

  def filter_spaces
    @spaces = Space.includes([:images]).order("star_rating DESC NULLS LAST")

    filter_by_location
    filter_by_title
    filter_by_space_types
    filter_and_order_by_facilities

    @filterable_facility_categories = FacilityCategory.includes(:facilities).all
    @filterable_space_types = SpaceType.all
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

    @spaces.filter_on_location(
      params[:north_west_lat],
      params[:north_west_lng],
      params[:south_east_lat],
      params[:south_east_lng]
    )
  end

  def filter_and_order_by_facilities
    return if params[:facilities].blank?

    @spaces = Space.filter_on_facilities(@spaces, params[:facilities])
  end
end
