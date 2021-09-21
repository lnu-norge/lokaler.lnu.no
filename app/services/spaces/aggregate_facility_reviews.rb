# frozen_string_literal: true

module Spaces
  class AggregateFacilityReviews < ApplicationService
    def initialize(space:)
      @space = space
      super()
    end

    def call # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      space.aggregated_facility_reviews.destroy_all

      a = space.facilities.order(:created_at).map do |facility|
        [facility.id, AggregatedFacilityReview.create!(experience: 'unknown', space: space, facility: facility)]
      end.to_h

      # Start a transaction because we may be modifying the 'experience' field many times
      # for a single aggregated review and we don't want to be hitting the DB for every 'experience' change
      AggregatedFacilityReview.transaction do
        space.facility_reviews.limit(10).each do |review|
          agg = a[review.facility.id]
          next unless agg

          if agg.unknown? && positive_review(review)
            agg.likely!
          elsif agg.unknown? && negative_review(review)
            agg.unlikely!
          elsif (agg.unlikely? && positive_review(review)) || (agg.likely? && negative_review(review))
            agg.maybe!
          elsif (agg.likely? && positive_review(review)) || (agg.unlikely? && negative_review(review))
            next # unchanged
          else
            raise "Unhandled aggregation combination #{agg.experience}:#{review.experience}"
          end
        end
      end

      a
    end

    private

    def positive_review(review)
      review.was_allowed? || review.was_allowed_but_bad?
    end

    def negative_review(review)
      review.was_not_available? || review.was_not_allowed?
    end

    attr_reader :space
  end
end
