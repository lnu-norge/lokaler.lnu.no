# frozen_string_literal: true

class Space < ApplicationRecord
  has_paper_trail skip: [:star_rating]

  has_many_attached :images
  has_many :facility_reviews, dependent: :restrict_with_exception
  has_many :aggregated_facility_reviews, dependent: :restrict_with_exception
  has_many :reviews, dependent: :restrict_with_exception

  belongs_to :space_owner
  belongs_to :space_type

  has_rich_text :how_to_book
  has_rich_text :who_can_use
  has_rich_text :pricing
  has_rich_text :terms
  has_rich_text :more_info

  validates :star_rating, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true

  after_create do
    aggregate_facility_reviews
    aggregate_star_rating
  end

  def reviews_for_facility(facility)
    AggregatedFacilityReview.find_by(space: self, facility: facility)
  end

  def facilities_in_category(category)
    AggregatedFacilityReview
      .includes(:facility)
      .where(space: self, facilities: { facility_category: category })
      .map do |result|
      {
        title: result.facility.title,
        icon: result.facility.icon,
        review: result.experience,
        tooltip: result.tooltip
      }
    end
  end

  def self.rect_of_spaces
    south_west_lat = 90
    south_west_lng = 180

    north_east_lat = -90
    north_east_lng = -180

    # Eventually this method will take some search parameters
    # but currently we just use the all the spaces in the db
    Space.all.find_each do |space|
      south_west_lat = space.lat if space.lat < south_west_lat
      south_west_lng = space.lng if space.lng < south_west_lng
      north_east_lat = space.lat if space.lat > north_east_lat
      north_east_lng = space.lng if space.lng > north_east_lng
    end

    { south_west: { lat: south_west_lat, lng: south_west_lng },
      north_east: { lat: north_east_lat, lng: north_east_lng } }
  end

  def aggregate_facility_reviews
    Spaces::AggregateFacilityReviewsService.call(space: self)
  end

  def aggregate_star_rating
    Spaces::AggregateStarRatingService.call(space: self)
  end
end
