# frozen_string_literal: true

module Spaces
  class AggregateStarRatingService < ApplicationService
    def initialize(space:)
      @space = space
      super()
    end

    def call
      if space.reviews.count.zero?
        space.update!(star_rating: nil)
        return
      end

      reviews_with_rating = space.reviews.where.not(star_rating: nil)

      star_rating = reviews_with_rating.all.sum(&:star_rating)

      space.update!(star_rating: star_rating / reviews_with_rating.count)

      space.star_rating
    end

    private

    attr_reader :space
  end
end
