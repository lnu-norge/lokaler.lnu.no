# frozen_string_literal: true

module SpacesConcern
  extend ActiveSupport::Concern

  def filter_on_space_types(spaces, space_types)
    return spaces if space_types.nil?

    spaces.select do |space|
      space_types.include?(space.space_type.id.to_s)
    end
  end

  def filter_on_facilities(spaces, facilities) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    return spaces if facilities.nil?

    spaces.select do |space|
      has_all_selected_facilities = true

      space.aggregated_facility_reviews.select do |review|
        if facilities.include?(review.facility.id.to_s) && (review.unknown? || review.impossible? || review.unlikely?)
          has_all_selected_facilities = false
        end
      end

      space if has_all_selected_facilities
    end
  end
end
