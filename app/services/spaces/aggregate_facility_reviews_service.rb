# frozen_string_literal: true

module Spaces
  class AggregateFacilityReviewsService < ApplicationService
    def initialize(space:)
      @space = space
      super()
    end

    def call
      space.space_facilities.destroy_all
      space.reload

      space_facilities = Facility.all.order(:created_at).map do |facility|
        SpaceFacility.create!(experience: "unknown", space: space, facility: facility)
      end

      # Start a transaction because we may be modifying the 'experience' field many times
      # for a single aggregated review and we don't want to be hitting the DB for every 'experience' change
      SpaceFacility.transaction do
        space_facilities.each do |space_facility|
          aggregate_reviews(space_facility)
        end
      end

      space_facilities
    end

    private

    def aggregate_reviews(space_facility) # rubocop:disable Metrics/AbcSize
      reviews = space.facility_reviews.where(facility: space_facility.facility).order(created_at: :desc).limit(5)
      count = reviews.count
      return space_facility.unknown! if count.zero?

      # Set criteria:
      impossible_threshold = [(count / 2.0).ceil, 2].max
      positive_threshold = (count / 3.0 * 2.0).ceil
      negative_threshold = (count / 3.0 * 2.0).ceil

      return space_facility.impossible! if reviews.impossible.count >= impossible_threshold
      return space_facility.likely! if  reviews.positive.count >= positive_threshold
      return space_facility.unlikely! if reviews.negative.count >= negative_threshold

      # Nothing else fits, so it's a maybe!
      space_facility.maybe!
    end

    attr_reader :space
  end
end
