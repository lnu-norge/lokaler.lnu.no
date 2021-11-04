# frozen_string_literal: true

module Spaces
  class AggregateFacilityReviewsService < ApplicationService
    def initialize(space:)
      @space = space
      super()
    end

    def call
      space.aggregated_facility_reviews.destroy_all
      space.reload

      aggregated_reviews = Facility.all.order(:created_at).map do |facility|
        AggregatedFacilityReview.create!(experience: "unknown", space: space, facility: facility)
      end

      # Start a transaction because we may be modifying the 'experience' field many times
      # for a single aggregated review and we don't want to be hitting the DB for every 'experience' change
      AggregatedFacilityReview.transaction do
        aggregated_reviews.each do |aggregated_review|
          aggregate_reviews(aggregated_review)
        end
      end

      aggregated_reviews
    end

    private

    def aggregate_reviews(aggregated_review) # rubocop:disable Metrics/AbcSize
      reviews = space.facility_reviews.where(facility: aggregated_review.facility).order(created_at: :desc).limit(5)
      count = reviews.count
      return aggregated_review.unknown! if count.zero?

      # Set criteria:
      impossible_threshold = (count / 2.0).ceil
      positive_threshold = (count / 3.0 * 2.0).ceil
      negative_threshold = (count / 3.0 * 2.0).ceil

      return aggregated_review.impossible! if reviews.impossible.count >= impossible_threshold
      return aggregated_review.likely! if  reviews.positive.count >= positive_threshold
      return aggregated_review.unlikely! if reviews.negative.count >= negative_threshold

      # Nothing else fits, so it's a maybe!
      aggregated_review.maybe!
    end

    attr_reader :space
  end
end
