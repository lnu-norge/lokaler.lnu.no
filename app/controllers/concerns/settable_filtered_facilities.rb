# frozen_string_literal: true

module SettableFilteredFacilities
  extend ActiveSupport::Concern

  private

  def set_filtered_facilities
    # TODO: This should be COMPLETELY redone or ripped out when we redo search
    mapbox_controller_search_url = cookies[:mapbox_controller_search_url]
    uri = Addressable::URI.parse(mapbox_controller_search_url)
    return if uri.blank?

    queries = uri.query_values
    return if queries.blank? || queries["selectedFacilities"].blank?

    selected_facilities_by_title = queries["selectedFacilities"].split(",")
    facility_ids = Facility.where(title: selected_facilities_by_title).pluck(:id)
    @filtered_facilities = Facility.includes(:facility_categories).find(facility_ids)
    @non_filtered_facilities = Facility.includes(:facility_categories).where.not(id: facility_ids)
  end
end
