# frozen_string_literal: true

class Space < ApplicationRecord
  has_paper_trail
  has_many_attached :images
  has_many :facilities, dependent: :restrict_with_exception
  has_many :facility_reviews, dependent: :restrict_with_exception
  has_many :reviews, dependent: :restrict_with_exception
  has_many :aggregated_facility_reviews, dependent: :restrict_with_exception

  belongs_to :space_owner
  belongs_to :space_type

  has_rich_text :how_to_book
  has_rich_text :who_can_use
  has_rich_text :pricing
  has_rich_text :terms
  has_rich_text :more_info

  validates :star_rating, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true

  def aggregate_facility_reviews
    Spaces::AggregateFacilityReviewsService.call(space: self)
  end

  def aggregate_star_rating
    Spaces::AggregateStarRatingService.call(space: self)
  end
end
