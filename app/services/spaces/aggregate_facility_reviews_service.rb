# frozen_string_literal: true

require_relative "concerns/countable_reviews"

module Spaces
  class AggregateFacilityReviewsService < ApplicationService
    include CountableReviews

    def initialize(space:, facilities: [])
      @space = space
      @facilities = facilities.any? ? facilities : Facility.order(:created_at)
      @space_facilities = @space.space_facilities
      @space_types = @space.space_types
      @facility_reviews = @space.facility_reviews_ordered_by_newest_first
      group_recent_facility_reviews_by_facility(count: 5)

      super()
    end

    def call
      aggregate_facilities
    end

    private

    def aggregate_facilities
      SpaceFacility.transaction do
        @facilities.each do |facility|
          aggregate_reviews(facility)
        end
      end
    end

    def aggregate_reviews(facility)
      space_facility = find_or_create_space_facility(facility)
      reviews = most_recent_facility_reviews_for(facility)
      belongs_to_space_type = facility_belongs_to_space_type(facility)

      return handle_zero_facility_reviews(space_facility, belongs_to_space_type) if reviews.blank?

      # Set criteria:
      two_out_of_three = (reviews.count / 3.0 * 2.0).ceil
      positive_threshold = count_of_positive(reviews) >= two_out_of_three
      impossible_threshold = count_of_impossible(reviews) >= two_out_of_three
      negative_threshold = count_of_negative(reviews) >= two_out_of_three

      set_relevance(space_facility, belongs_to_space_type, positive_threshold)
      set_experience(space_facility, positive_threshold, impossible_threshold, negative_threshold)
    end

    # NB: Does not set relevance for the maybe scenario, that is set in set_experience
    def set_relevance(space_facility, belongs_to_space_type, positive_threshold)
      return space_facility.update(relevant: false) unless positive_threshold || belongs_to_space_type

      space_facility.update(relevant: true)
    end

    def set_experience(space_facility, positive_threshold, impossible_threshold, negative_threshold)
      return space_facility.update(experience: "likely") if positive_threshold
      return space_facility.update(experience: "impossible") if impossible_threshold
      return space_facility.update(experience: "unlikely") if negative_threshold

      # Nothing else fits, so it's a _relevant_ maybe!
      space_facility.update(experience: "maybe", relevant: true)
    end

    def handle_zero_facility_reviews(space_facility, belongs_to_space_type)
      return space_facility.update(experience: "unknown", relevant: true) if belongs_to_space_type

      space_facility.update(experience: "unknown", relevant: false)
    end

    def facility_belongs_to_space_type(facility)
      @space_types.find do |space_type|
        space_type.facilities.include? facility
      end.present?
    end

    def find_or_create_space_facility(facility)
      space_facility = @space_facilities.find { |sf| sf.facility_id == facility.id }
      return space_facility if space_facility

      SpaceFacility.create(facility_id: facility.id, space_id: @space.id)
    end

    attr_reader :space
  end
end
