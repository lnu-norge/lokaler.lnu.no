# frozen_string_literal: true

module FilterableSpaces
  private

  def filter_spaces(params)
    space_types = params[:space_types]&.map(&:to_i)

    spaces = Space.includes([:images]).filter_on_location(
      params[:north_west_lat],
      params[:north_west_lng],
      params[:south_east_lat],
      params[:south_east_lng]
    )

    spaces = spaces.filter_on_title(params[:search_for_title]) if params[:search_for_title].present?
    spaces = spaces.filter_on_space_types(space_types) if space_types.present?

    filter_on_facilities_and_return_ordered_spaces(spaces:, params:)
  end

  def filter_on_facilities_and_return_ordered_spaces(spaces:, params:)
    facilities = params[:facilities]&.map(&:to_i)

    return spaces.order("star_rating DESC NULLS LAST") if facilities.blank?

    Space.filter_on_facilities(spaces, params[:facilities])
  end
end
