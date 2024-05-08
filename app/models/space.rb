# frozen_string_literal: true

class Space < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_paper_trail skip: [:star_rating]

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

  scope :filter_on_title, ->(title) { where("title ILIKE ?", "%#{title}%") }
  scope :filter_on_space_types, ->(space_type_ids) { joins(:space_types).where(space_types: space_type_ids) }
  scope :filter_on_location, lambda { |north_west_lat, north_west_lng, south_east_lat, south_east_lng|
    where(":north_west_lat >= lat AND :north_west_lng <= lng AND :south_east_lat <= lat AND :south_east_lng >= lng",
          north_west_lat:,
          north_west_lng:,
          south_east_lat:,
          south_east_lng:)
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
        :space_types
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

  scope :filter_and_order_by_facilities, lambda { |facility_ids|
    # NB: This grouping means that the results are not countable with .size or .count
    group(:id)
      .joins(:space_facilities)
      .where(space_facilities: { relevant: true, facility_id: facility_ids })
      .order(Arel.sql("
                    SUM(
                                     CASE
                                        WHEN space_facilities.experience = 4 THEN 3.0 -- likely
                                        WHEN space_facilities.experience = 3 THEN 2.0 -- maybe
                                        WHEN space_facilities.experience = 2 THEN -1.0 -- unlikely
                                        WHEN space_facilities.experience = 1 THEN -2.0 -- impossible
                                        WHEN space_facilities.relevant THEN 1.0 -- unknown experience, but relevant
                                        ELSE 0.0 -- unknown experience, irrelevant facility
                                      END
                    )
                DESC"),
             Arel.sql(
               "COALESCE((spaces.star_rating - 2.9) / 10, 0) DESC"
             ))
  }

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

  def render_map_marker
    html = SpacesController.render partial: "spaces/index/map_marker", locals: { space: self }
    { lat:, lng:, id:, html: }
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
