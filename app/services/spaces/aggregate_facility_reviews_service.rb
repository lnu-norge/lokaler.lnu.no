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

      # Start a transaction because we may be modifying the 'experience' field many times
      # for a single aggregated review and we don't want to be hitting the DB for every 'experience' change
      SpaceFacility.transaction do
        facilities = Facility.all.order(:created_at).map do |facility|
          SpaceFacility.new(experience: "unknown", space: space, facility: facility)
        end

        facilities.each do |space_facility|
          space_facility.save! if aggregate_reviews(space_facility).present?
        end
      end
    end

    private

    def aggregate_reviews(space_facility) # rubocop:disable Metrics/AbcSize
      reviews = space.facility_reviews.where(facility: space_facility.facility).order(created_at: :desc).limit(5)
      count = reviews.count

      return handle_zero_facility_reviews(space, space_facility) if count.zero?

      # Set criteria:
      impossible_threshold = (count / 2.0).ceil
      positive_threshold = (count / 3.0 * 2.0).ceil
      negative_threshold = (count / 3.0 * 2.0).ceil

      return space_facility.impossible! if reviews.impossible.count >= impossible_threshold
      return space_facility.likely! if  reviews.positive.count >= positive_threshold
      return space_facility.unlikely! if reviews.negative.count >= negative_threshold

      # Nothing else fits, so it's a maybe!
      space_facility.maybe!
    end

    def handle_zero_facility_reviews(space, space_facility)
      space_types_with_relevant_facilities = space.space_types.filter do |space_type|
        space_type.facilities.include? space_facility.facility
      end

      return nil if space_types_with_relevant_facilities.empty?

      space_facility.unknown!
    end

    attr_reader :space
  end
end
