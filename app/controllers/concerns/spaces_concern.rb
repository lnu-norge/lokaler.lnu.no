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

    result = spaces.map do |space|
      match_count = 0
      space.aggregated_facility_reviews.each do |review|
        if facilities.include?(review.facility_id.to_s) && (review.unknown? || review.maybe? || review.likely?)
          match_count += 1
        end
      end

      next if match_count.zero?

      OpenStruct.new(match_count: match_count, space: space)
    end

    result.sort_by(&:match_count).map(&:space)
  end
end
