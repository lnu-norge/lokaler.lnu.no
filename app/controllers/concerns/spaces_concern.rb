# frozen_string_literal: true

module SpacesConcern

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
    end.compact

    result.sort_by(&:match_count).map(&:space)
  end
end
