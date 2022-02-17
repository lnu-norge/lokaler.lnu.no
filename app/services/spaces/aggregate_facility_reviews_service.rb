# frozen_string_literal: true

module Spaces
  class AggregateFacilityReviewsService < ApplicationService
    def initialize(space:, facilities: [])
      @space = space
      @facilities = facilities
      super()
    end

    def call
      if @facilities.any?
        aggregate_specific_facilities
      else
        aggregate_all_facilities
      end
    end

    private

    def aggregate_specific_facilities
      SpaceFacility.transaction do
        @facilities.each do |facility|
          aggregate_reviews(facility)
        end
      end
    end

    def aggregate_all_facilities
      # Start a transaction because we may be modifying the 'experience' field many times
      # for a single aggregated review and we don't want to be hitting the DB for every 'experience' change
      SpaceFacility.transaction do
        Facility.all.order(:created_at).each do |facility|
          aggregate_reviews(facility)
        end
      end
    end

    def aggregate_reviews(facility) # rubocop:disable Metrics/AbcSize
      space_facility = SpaceFacility.find_or_create_by(space: @space, facility: facility)

      reviews = space.facility_reviews.where(facility: facility).order(created_at: :desc).limit(5)
      count = reviews.count

      belongs_to_space_type = facility_belongs_to_space_type(facility)

      return handle_zero_facility_reviews(space_facility, belongs_to_space_type) if count.zero?

      # Set criteria:
      positive_threshold = reviews.positive.count >= (count / 3.0 * 2.0).ceil
      impossible_threshold = reviews.impossible.count >= (count / 2.0).ceil
      negative_threshold = reviews.negative.count >= (count / 3.0 * 2.0).ceil

      set_relevance(space_facility, belongs_to_space_type, positive_threshold)

      set_experience(space_facility, positive_threshold, impossible_threshold, negative_threshold)
    end

    # NB: Does not set relevance for the maybe scenario, that is set in set_experience
    def set_relevance(space_facility, belongs_to_space_type, positive_threshold)
      return space_facility.not_relevant! unless positive_threshold || belongs_to_space_type

      space_facility.relevant!
    end

    def set_experience(space_facility, positive_threshold, impossible_threshold, negative_threshold)
      return space_facility.likely! if positive_threshold
      return space_facility.impossible! if impossible_threshold
      return space_facility.unlikely! if negative_threshold

      # Nothing else fits, so it's a _relevant_ maybe!
      space_facility.maybe! && space_facility.relevant!
    end

    def handle_zero_facility_reviews(space_facility, belongs_to_space_type)
      return space_facility.unknown! && space_facility.not_relevant! unless belongs_to_space_type

      space_facility.unknown! && space_facility.relevant!
    end

    def facility_belongs_to_space_type(facility)
      space.space_types.filter do |space_type|
        space_type.facilities.include? facility
      end.any?
    end

    attr_reader :space
  end
end
