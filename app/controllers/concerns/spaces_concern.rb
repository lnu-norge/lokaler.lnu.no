# frozen_string_literal: true

module SpacesConcern
  extend ActiveSupport::Concern

  def filter_on_space_types(spaces, space_types)
    return spaces if space_types.nil?

    spaces.select do |space|
      space_types.include?(space.space_type_id.to_s)
    end
  end

  def filter_on_facilities(spaces, facilities) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    return spaces if facilities.nil?

    spaces.reject do |space|
      space.aggregated_facility_reviews.select do |review|
        if facilities.include?(review.facility_id.to_s) && (review.unknown? || review.impossible? || review.unlikely?)
          review
        end
      end.empty?
    end
  end
end
