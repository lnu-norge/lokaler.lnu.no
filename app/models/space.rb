# frozen_string_literal: true

class Space < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_paper_trail skip: [:star_rating]

  has_many :images, dependent: :destroy
  has_many :facility_reviews, dependent: :restrict_with_exception
  has_many :aggregated_facility_reviews, dependent: :restrict_with_exception
  has_many :reviews, dependent: :restrict_with_exception
  has_many :space_contacts, dependent: :restrict_with_exception

  belongs_to :space_group, optional: true
  accepts_nested_attributes_for :space_group

  scope :filter_on_space_types, ->(space_type_ids) { where(space_type_id: space_type_ids) }
  scope :filter_on_location, lambda { |north_west_lat, north_west_lng, south_east_lat, south_east_lng|
    where(":north_west_lat >= lat AND :north_west_lng <= lng AND :south_east_lat <= lat AND :south_east_lng >= lng",
          north_west_lat: north_west_lat,
          north_west_lng: north_west_lng,
          south_east_lat: south_east_lat,
          south_east_lng: south_east_lng)
  }

  belongs_to :space_type

  has_rich_text :how_to_book
  has_rich_text :who_can_use
  has_rich_text :pricing
  has_rich_text :terms
  has_rich_text :more_info
  has_rich_text :facility_description

  include ParseUrlHelper
  before_validation :parse_url

  validates :star_rating, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true
  validates :url, url: { allow_blank: true, public_suffix: true }
  validates :title, :address, :post_address, :post_number, :lat, :lng, presence: true

  after_create do
    aggregate_facility_reviews
    aggregate_star_rating
  end

  def reviews
    Review.includes([:user, :facility_reviews]).where(space_id: id)
  end

  def reviews_for_facility(facility)
    AggregatedFacilityReview.find_by(space: self, facility: facility).experience
  end

  def facilities_in_category(category)
    AggregatedFacilityReview
      .includes(:facility)
      .where(space: self, facilities: { facility_category: category })
      .map do |result|
      {
        title: result.facility.title,
        icon: result.facility.icon,
        review: result.experience
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
      next unless space.lat.present? && space.lng.present?

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

  def self.search_for_address(address:, post_number:, post_address:)
    results = Spaces::LocationSearchService.call(
      address: address,
      post_number: post_number,
      post_address: post_address
    )

    return nil if results.count > 1 || results.empty?

    results.first
  end

  def potential_duplicates
    Spaces::DuplicateDetectorService.call(self)
  end

  # Move this somewhere better, either a service or figure out a way to make it a scope
  # NOTE: this expects a scope for spaces but returns an array
  # preferably we would find some way to return a scope too
  def self.filter_on_facilities(spaces, facilities) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    results = spaces.includes(:aggregated_facility_reviews).filter_map do |space|
      score = 0
      space.aggregated_facility_reviews.each do |review|
        next unless facilities.include?(review.facility_id)

        # The more correct matches the lower the number.
        # this is so the sort_by later will be correct as it sorts by lowest first
        # we could do a reverse on the result of sort_by but this will incur
        # a performance overhead
        if review.likely?
          score -= 2
        elsif review.maybe?
          score -= 1
        elsif review.unlikely?
          score += 1
        elsif review.impossible?
          score += 2
        end
      end

      OpenStruct.new(score: score, space: space)
    end

    results.sort_by(&:score).map(&:space)
  end

  def merge_paper_trail_versions
    PaperTrail::Version
      .or(PaperTrail::Version.where(item: self))
      .or(PaperTrail::Version.where(item: how_to_book))
      .or(PaperTrail::Version.where(item: who_can_use))
      .or(PaperTrail::Version.where(item: pricing))
      .or(PaperTrail::Version.where(item: terms))
      .or(PaperTrail::Version.where(item: more_info))
  end

  def star_rating_s
    star_rating || " - "
  end

  def render_map_marker
    html = SpacesController.render partial: "spaces/index/map_marker", locals: { space: self }
    { lat: lat, lng: lng, id: id, html: html }
  end
end
