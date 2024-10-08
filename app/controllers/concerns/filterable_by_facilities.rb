# frozen_string_literal: true

module FilterableByFacilities
  extend ActiveSupport::Concern
  include SanitizeableIdList

  private

  def set_filterable_facility_categories
    @filterable_facility_categories = FacilityCategory.includes(:facilities).all
  end

  def set_filtered_facilities
    facility_ids = sanitize_id_list(params[:facilities])
    @filtered_facilities = Facility.includes(:facility_categories).find(facility_ids)
  end

  def filter_and_order_by_facilities
    sanitized_facility_list = sanitize_id_list(params[:facilities])
    return @filtered_spaces.order_by_star_rating if sanitized_facility_list.blank?

    @filtered_spaces.filter_and_order_by_facilities(sanitized_facility_list)
  end
end
