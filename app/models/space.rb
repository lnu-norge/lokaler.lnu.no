# frozen_string_literal: true

class Space < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_paper_trail skip: [:star_rating]

  belongs_to :fylke, class_name: "Fylke", optional: true
  belongs_to :kommune, class_name: "Kommune", optional: true

  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images

  has_many :facility_reviews, dependent: :destroy
  accepts_nested_attributes_for :facility_reviews

  has_many :space_facilities, dependent: :destroy
  accepts_nested_attributes_for :space_facilities

  has_many :reviews, dependent: :destroy
  accepts_nested_attributes_for :reviews

  has_many :space_contacts, dependent: :destroy
  accepts_nested_attributes_for :space_contacts

  belongs_to :space_group, optional: true
  accepts_nested_attributes_for :space_group

  has_many :space_types_relations, dependent: :destroy
  has_many :space_types, through: :space_types_relations, dependent: :destroy
  accepts_nested_attributes_for :space_types

  has_and_belongs_to_many :personal_space_lists
  has_many :personal_data_on_space_in_lists, dependent: :destroy

  scope :filter_on_title, ->(title) { where("title ILIKE ?", "%#{title}%") }
  scope :filter_on_space_types, lambda { |space_type_ids|
    joins(:space_types).where(space_types: { id: space_type_ids })
  }
  scope :filter_on_fylker_or_kommuner, lambda { |fylke_ids:, kommune_ids:|
    where(fylke_id: fylke_ids).or(where(kommune_id: kommune_ids))
  }
  scope :filter_on_map_bounds, lambda { |north_west_lat, north_west_lng, south_east_lat, south_east_lng|
    where(":north_west_lat >= lat AND :north_west_lng <= lng AND :south_east_lat <= lat AND :south_east_lng >= lng",
          north_west_lat:,
          north_west_lng:,
          south_east_lat:,
          south_east_lng:)
  }
  scope :filter_and_order_by_facilities, lambda { |facility_ids|
    joins(:space_facilities)
      .where(space_facilities: {
               # Facilities are selected
               facility_id: facility_ids,
               # And either have user input on this space, or are usually relevant for the space type
               relevant: true,
               # and have a positive or neutral experience
               experience: [:unknown, :maybe, :likely]
             })
      .group("spaces.id")
      # First sort by facility score, then by star rating to break any ties
      # Star ratings below 3 should be sorted below those who have no rating
      # Coalesce makes sure that 0 is returned if there is no rating
      .order(
        Arel.sql("SUM(space_facilities.score) DESC, COALESCE((spaces.star_rating - 2.9), 0) DESC")
      )
  }

  # This scope cuts the db calls when aggregating space_facilities
  has_many :facility_reviews_ordered_by_newest_first, -> { order(created_at: :desc) },
           class_name: "FacilityReview", dependent: :destroy, inverse_of: :space

  scope :with_aggregation_data, lambda {
    preload(
      :space_facilities,
      :facility_reviews_ordered_by_newest_first,
      space_types: [
        :facilities
      ]
    )
  }

  scope :with_images, lambda {
    includes(
      {
        images: [
          {
            image_attachment: :blob
          }
        ]
      }
    )
  }

  scope :order_by_star_rating, lambda {
    order(
      "spaces.star_rating DESC NULLS LAST"
    )
  }

  scope :includes_data_for_filter_list, lambda {
    with_images
      .with_space_facilities
      .includes(
        :reviews,
        space_types_relations: [
          :space_type
        ]
      )
  }

  scope :with_space_facilities, lambda {
    includes(
      {
        space_facilities: {
          facility: [
            :facility_categories,
            :facility_reviews
          ]
        }
      }
    )
  }

  scope :with_reviews, lambda {
    includes({
               reviews: [
                 :user
               ]
             })
  }

  scope :with_rich_text_from_space_group, lambda {
    includes(
      {
        space_group: %i[
          rich_text_how_to_book
          rich_text_pricing
          rich_text_who_can_use
          rich_text_terms
          rich_text_about
          space_contacts
        ]
      }
    )
  }

  scope :includes_data_for_show, lambda {
    with_all_rich_text
      .with_rich_text_from_space_group
      .with_images
      .with_space_facilities
      .with_reviews
      .includes(
        :space_types,
        :space_contacts
      )
  }

  has_rich_text :how_to_book
  has_rich_text :who_can_use
  has_rich_text :pricing
  has_rich_text :terms
  has_rich_text :more_info

  include ParseUrlHelper
  before_validation :parse_url
  before_validation :set_geo_data_from_lng_lat, if: :lat_lng_changed?

  validates :star_rating, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true
  validates :url, url: { allow_blank: true, public_suffix: true }
  validates :title, :address, :post_address, :post_number, :lat, :lng, :geo_point, presence: true
  validates :lat, :lng, numericality: { other_than: 0 }

  after_create do
    aggregate_facility_reviews
    aggregate_star_rating
    clear_vector_tile_caches
  end

  after_update :clear_vector_tile_caches, if: :saved_changes_to_lat_or_lng?

  after_destroy do
    clear_vector_tile_caches
  end

  def reviews_for_facility(facility)
    space_facilities.find_by(facility:).experience
  end

  def relevance_of_facility(facility)
    space_facilities.find_by(facility:).relevant
  end

  def self.rect_of_spaces
    south_west_lat = 90
    south_west_lng = 180

    north_east_lat = -90
    north_east_lng = -180

    # Eventually this method will take some search parameters
    # but currently we just use the all the spaces in the db
    Space.find_each do |space|
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
    space = Space.with_aggregation_data.find(id)

    Spaces::AggregateFacilityReviewsService.call(space:, facilities:)
  end

  def aggregate_star_rating
    Spaces::AggregateStarRatingService.call(space: self)
  end

  def self.search_for_address(address:, post_number:)
    results = Spaces::LocationSearchService.call(
      address:,
      post_number:
    )

    full_information = post_number&.length == 4 && address.present? && results.present?
    return results.first if results.count == 1 || full_information

    # Otherwise, return nil
    nil
  end

  def potential_duplicates
    Spaces::DuplicateDetectorService.call(self)
  end

  # Space Facilities that are typically relevant for the space
  # Either because they share a space type with the space
  # or because someone has said that they are relevant for
  # this specific space by setting a space_facilities experience.
  #
  # Can be grouped by category by passing grouped: true, and
  # if a user is defined, include facility reviews for that user
  def relevant_space_facilities(grouped: false, user: nil)
    filtered_space_facilities(relevant: true, grouped:, user:)
  end

  # Space Facilities that are typically NOT relevant for the space
  # Because they DO NOT share a space type with the space AND
  # no one has given a space_facility experience for them.
  #
  # Can be grouped by category by passing grouped: true.
  # Cannot have facility reviews, else they would be relevant.
  def non_relevant_space_facilities(grouped: false)
    filtered_space_facilities(relevant: false, grouped:)
  end

  def filtered_space_facilities(relevant: true, grouped: false, user: nil)
    ungrouped_facilities = space_facilities
                           .includes(
                             facility: [
                               :facility_reviews,
                               :facilities_categories
                             ]
                           )
                           .where(relevant:)
                           .order("facilities.title")

    return ungrouped_facilities unless grouped

    group_space_facilities(ungrouped_facilities:, user:)
  end

  # Facilities (found through space facilities) that are relevant.
  def relevant_facilities
    space_facilities.includes(:facility).where(relevant: true).map(&:facility)
  end

  # Groups given facilities by their category
  # { category_id: [facility_1, facility_2, ...] }
  def group_space_facilities(ungrouped_facilities:, user: nil)
    ungrouped_facilities.each_with_object({}) do |space_facility, memo|
      space_facility.facility.facilities_categories.each do |facility_category|
        memo[facility_category.facility_category_id] ||= {
          category: facility_category.facility_category,
          space_facilities: []
        }

        facility_data = facility_data_from_space_facility(space_facility:, facility_category:, user:)

        memo[facility_category.facility_category_id][:space_facilities] << facility_data
      end
    end.sort_by(&:first) # sorts by category id
  end

  def facility_data_from_space_facility(space_facility:, facility_category:, user:)
    data = {
      facility: space_facility.facility,
      space_facility:,
      facility_category: facility_category.facility_category
    }

    add_current_user_facility_review_to_data(data:, space_facility:, user:)
  end

  def add_current_user_facility_review_to_data(data:, space_facility:, user:)
    return data if user.blank?

    if space_facility.facility.facility_reviews.present?
      current_user_review = space_facility.facility.facility_reviews.find_by(user:,
                                                                             space: self)
    end

    data[:facility_review] =
      (current_user_review.presence || FacilityReview.new(facility_id: id, space_id: @space, user_id: user.id))

    data
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

  def render_map_marker(options: {})
    html = SpacesController.render partial: "spaces/index/map_marker", locals: { space: self, **options }
    { lat:, lng:, id:, html: }
  end

  def space_types_joined
    space_types.map { |space_type| space_type.type_name.humanize }.join(", ")
  end

  def to_param
    return nil unless persisted?

    [id, title.parameterize].join("-")
  end

  def set_geo_data
    set_geo_point
    set_geo_areas_space_belongs_to
  end

  private

  def clear_vector_tile_caches
    Rails.cache.delete_matched("#{Spaces::MapVectorController::VECTOR_TILE_CACHE_KEY_PREFIX}*")
  end

  def lat_lng_changed?
    lat_changed? || lng_changed?
  end

  def saved_changes_to_lat_or_lng?
    saved_change_to_lat? || saved_change_to_lng?
  end

  def lat_lng_set?
    lat.present? && lng.present?
  end

  def geo_point_equal_to_lng_lat?
    geo_point.present? && geo_point.x.to_d == lng.to_d && geo_point.y.to_d == lat.to_d
  end

  def set_geo_data_from_lng_lat
    return unless lat_lng_set?
    return if geo_point_equal_to_lng_lat?

    set_geo_data
  end

  def set_geo_point
    self.geo_point = Geo.point(lng, lat) # Postgis format
  end

  def set_geo_areas_space_belongs_to
    # Find the Fylke that contains this point
    fylke = Fylke.where("ST_Contains(geo_area, ?)", geo_point).first
    self.fylke = fylke if fylke

    # Find the Kommune that contains this point
    kommune = Kommune.where("ST_Contains(geo_area, ?)", geo_point).first
    self.kommune = kommune if kommune
  end
end

# == Schema Information
#
# Table name: spaces
#
#  id                   :bigint           not null, primary key
#  address              :string
#  geo_point            :geography        not null, point, 4326
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
#  fylke_id             :bigint
#  kommune_id           :bigint
#  space_group_id       :bigint
#
# Indexes
#
#  index_spaces_on_fylke_id        (fylke_id)
#  index_spaces_on_geo_point       (geo_point) USING gist
#  index_spaces_on_kommune_id      (kommune_id)
#  index_spaces_on_space_group_id  (space_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (fylke_id => geographical_areas.id)
#  fk_rails_...  (kommune_id => geographical_areas.id)
#  fk_rails_...  (space_group_id => space_groups.id)
#
