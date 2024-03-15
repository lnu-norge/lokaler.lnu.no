# frozen_string_literal: true

module FacilityReviewsHelper
  def target_id_for_categorized_facility(facility_id:, category_id:)
    "facility_#{facility_id}_in_category_#{category_id}"
  end
end
