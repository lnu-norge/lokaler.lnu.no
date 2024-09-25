# frozen_string_literal: true

module SettableFilteredFacilities
  extend ActiveSupport::Concern

  private

  def set_filtered_facilities
    last_filter_params = session[:last_filter_params]
    return if last_filter_params.blank? || last_filter_params["facilities"].blank?

    facility_ids = last_filter_params["facilities"]&.map(&:to_i)
    @filtered_facilities = Facility.includes(:facility_categories).find(facility_ids)
    @non_filtered_facilities = Facility.includes(:facility_categories).where.not(id: facility_ids)
  end
end
