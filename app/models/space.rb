# frozen_string_literal: true

class Space < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_paper_trail skip: [:star_rating]

  has_many :images, dependent: :destroy
  has_many :facility_reviews, dependent: :destroy
  has_many :space_facilities, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :space_contacts, dependent: :destroy

  belongs_to :space_group, optional: true
  accepts_nested_attributes_for :space_group

  scope :filter_on_space_types, ->(space_type_ids) { joins(:space_types).where(space_types: space_type_ids).distinct }
  scope :filter_on_location, lambda { |north_west_lat, north_west_lng, south_east_lat, south_east_lng|
    where(":north_west_lat >= lat AND :north_west_lng <= lng AND :south_east_lat <= lat AND :south_east_lng >= lng",
          north_west_lat: north_west_lat,
          north_west_lng: north_west_lng,
          south_east_lat: south_east_lat,
          south_east_lng: south_east_lng)
  }

  has_many :space_types_relations, dependent: :destroy
  has_many :space_types, through: :space_types_relations, dependent: :destroy

  has_rich_text :how_to_book
  has_rich_text :who_can_use
  has_rich_text :pricing
  has_rich_text :terms
  has_rich_text :more_info

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
    Review.includes([:user]).where(space_id: id)
  end

  def reviews_for_facility(facility)
    space_facilities.find_by(facility: facility).experience
  end

  def relevance_of_facility(facility)
    space_facilities.find_by(facility: facility).relevant
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

  def aggregate_facility_reviews(facilities: [])
    Spaces::AggregateFacilityReviewsService.call(space: self, facilities: facilities)
  end

  def aggregate_star_rating
    Spaces::AggregateStarRatingService.call(space: self)
  end

  def self.search_for_address(address:, post_number:)
    results = Spaces::LocationSearchService.call(
      address: address,
      post_number: post_number
    )

    full_information = post_number&.length == 4 && address.present? && results.present?
    return results.first if results.count == 1 || full_information

    # Otherwise, return nil
    nil
  end

  def potential_duplicates
    Spaces::DuplicateDetectorService.call(self)
  end

  # Move this somewhere better, either a service or figure out a way to make it a scope
  # NOTE: this expects a scope for spaces but returns an array
  # preferably we would find some way to return a scope too
  def self.filter_on_facilities(spaces, filtered_facilities)
    results = spaces.includes(:space_facilities)
                    .where(space_facilities: { relevant: true, facility_id: filtered_facilities })
                    .filter_map(&:score_by_filter_on_facilities)

    results.sort_by(&:score).map(&:space)
  end

  def score_by_filter_on_facilities
    space_score = 0.0
    # The more correct matches the lower the number.
    # this is so the sort_by later will be correct as it sorts by lowest first
    # we could do a reverse on the result of sort_by but this will incur
    # a performance overhead

    space_facilities.each do |space_facility|
      space_score -= score_from_experience(space_facility)
    end

    # Add a score for the star_rating to use as a tie-breaker.
    space_score -= score_from_star_rating

    OpenStruct.new(score: space_score, space: self) # rubocop:disable Style/OpenStructUse
  end

  def score_from_experience(space_facility)
    return 3.0 if space_facility.likely?
    return 2.0 if space_facility.maybe?
    return 1.0 if space_facility.unknown?
    return -1.0 if space_facility.unlikely?

    -2.0 if space_facility.impossible?
  end

  def score_from_star_rating
    # Star ratings under 3 should score so the space is filtered lower,
    # star ratings at 3 or over should place the search result higher.
    #
    # Star ratings go from 1-5, if present, so just subtract 2.9 to get the right
    # sorting, then divide by 10 to make it less relevant than scores based on matches
    return 0 if star_rating.blank?

    (star_rating - 2.9) / 10
  end

  # Groups all of the users facility reviews into a hash like
  # { category_id: { facility_id: review } }
  def reviews_for_categories(user)
    user.facility_reviews
        .where(space: self)
        .includes(facility: [:facilities_categories])
        .joins(facility: [:facilities_categories])
        .each_with_object({}) do |review, memo|
      review.facility.facilities_categories.each do |facility_category|
        memo[facility_category.facility_category_id] ||= {}
        memo[facility_category.facility_category_id][review.facility.id] = review
      end
    end
  end

  # Space Facilities that are typically relevant for the space
  # Either because they share a space type with the space
  # or because someone has said that they are relevant for
  # this specific space by setting a space_facilities experience.
  #
  # Can be grouped by category by passing grouped: true
  def relevant_space_facilities(grouped: false)
    relevant = space_facilities.includes(facility: [:facilities_categories]).where(relevant: true)

    return relevant unless grouped

    group_space_facilities(relevant)
  end

  # Facilities (not space facilities :P) that are relevant.
  def relevant_facilities
    space_facilities.where(relevant: true).map(&:facility)
  end

  # Space Facilities that are typically NOT relevant for the space
  # Because they DO NOT share a space type with the space AND
  # no one has given a space_facility experience for them.
  #
  # Can be grouped by category by passing grouped: true
  def non_relevant_space_facilities(grouped: false)
    non_relevant = space_facilities.includes(facility: [:facilities_categories]).where(relevant: false)

    return non_relevant unless grouped

    group_space_facilities(non_relevant)
  end

  # Groups given facilities by their category
  # { category_id: [facility_1, facility_2, ...] }
  def group_space_facilities(ungrouped_facilities) # rubocop:disable Metrics/AbcSize
    ungrouped_facilities.each_with_object({}) do |space_facility, memo|
      space_facility.facility.facilities_categories.each do |facility_category|
        memo[facility_category.facility_category_id] ||= {
          category: facility_category.facility_category,
          space_facilities: []
        }
        memo[facility_category.facility_category_id][:space_facilities] << {
          id: space_facility.facility.id,
          title: space_facility.facility.title,
          description: space_facility.description,
          review: space_facility.experience,
          space_types: space_facility.facility.space_types,
          relevant: space_facility.relevant
        }
      end
    end.sort_by(&:first) # sorts by category id
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

  def space_types_joined
    space_types.map { |space_type| space_type.type_name.humanize }.join(", ")
  end

  def to_param
    return nil unless persisted?

    [id, title.parameterize].join("-")
  end
end

# == Schema Information
#
# Table name: spaces
#
#  id                   :bigint           not null, primary key
#  address              :string
#  lat                  :decimal(, )
#  lng                  :decimal(, )
#  location_description :text
#  municipality_code    :string
#  organization_number  :string
#  post_address         :string
#  post_number          :string
#  star_rating          :decimal(2, 1)
#  title                :string           not null
#  url                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  space_group_id       :bigint
#
# Indexes
#
#  index_spaces_on_space_group_id  (space_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (space_group_id => space_groups.id)
#
