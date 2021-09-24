# frozen_string_literal: true

module Spaces
  class AggregateStarRatingService < ApplicationService
    def initialize(space:)
      @space = space
      super()
    end

    def call
      space.update!(star_rating: nil) if space.reviews.count.zero?

      star_rating = space.reviews.all.sum(&:star_rating)

      space.update!(star_rating: star_rating / space.reviews.count)
    end

    private

    attr_reader :space
  end
end
