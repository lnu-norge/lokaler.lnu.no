# frozen_string_literal: true

module Spaces
  class AggregateFacilityReviewsService < ApplicationService
    def initialize(space:)
      @space = space
      super()
    end

    def call # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      space.aggregated_facility_reviews.destroy_all
      space.reload

      aggregated_reviews = Facility.all.order(:created_at).map do |facility|
        [facility.id, AggregatedFacilityReview.create!(experience: 'unknown', space: space, facility: facility)]
      end.to_h

      # Start a transaction because we may be modifying the 'experience' field many times
      # for a single aggregated review and we don't want to be hitting the DB for every 'experience' change
      AggregatedFacilityReview.transaction do
        space.facility_reviews.limit(10).each do |review|
          aggregate = aggregated_reviews[review.facility.id]
          next unless aggregate

          if aggregate.unknown? && positive_review(review)
            aggregate.likely!
          elsif aggregate.unknown? && negative_review(review)
            aggregate.unlikely!
          elsif (aggregate.unlikely? && positive_review(review)) || (aggregate.likely? && negative_review(review))
            aggregate.maybe!
          elsif (aggregate.likely? && positive_review(review)) || (aggregate.unlikely? && negative_review(review))
            next # unchanged
          elsif impossible_review(review)
            aggregate.impossible!
          elsif aggregate.impossible? && negative_review(review)
            aggregate.impossible!
          else
            raise "Unhandled aggregation combination #{aggregate.experience}:#{review.experience}"
          end
        end
      end

      aggregated_reviews
    end

    private

    def positive_review(review)
      review.was_allowed? || review.was_allowed_but_bad?
    end

    def negative_review(review)
      review.was_not_allowed?
    end

    def impossible_review(review)
      review.was_not_available?
    end

    attr_reader :space
  end
end
