# frozen_string_literal: true

class Review < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :space
  belongs_to :organization, optional: true

  has_many :facility_reviews, dependent: :destroy
  accepts_nested_attributes_for :facility_reviews

  enum how_much: { custom_how_much: 0, whole_space: 1, one_room: 2 }
  enum how_long: { custom_how_long: 0, one_weekend: 1, one_evening: 2 }
  enum type_of_contact: { only_contacted: 0, not_allowed_to_use: 1, been_there: 2 }

  validates :title,
            length: { minimum: 4, maximum: 80 },
            presence: true,
            if: ->(r) { r.been_there? || r.not_allowed_to_use? }
  validates :user, :space, presence: true
  validates :how_much, inclusion: { in: how_muches.keys }, allow_nil: true
  validates :how_long, inclusion: { in: how_longs.keys }, allow_nil: true
  validates :type_of_contact, inclusion: { in: type_of_contacts.keys }
  validates :how_much_custom, presence: true, if: :custom_how_much?
  validates :how_long_custom, presence: true, if: :custom_how_long?
  validates :price, numericality: { greater_than: 0 }, allow_nil: true
  validates :star_rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, if: :been_there?
  validates :facility_reviews, presence: true, if: :only_contacted?

  after_save { space.aggregate_facility_reviews }
  after_destroy { space.aggregate_facility_reviews }

  after_save { space.aggregate_star_rating }
  after_destroy { space.aggregate_star_rating }

  def facility_review_for(facility)
    facility_reviews.find_by(facility: facility.id) || FacilityReview.new(
      review: self,
      facility: facility
    )
  end

  ICONS_FOR_TYPE_OF_CONTACT = {
    "been_there" => "facility_status/likely",
    "not_allowed_to_use" => "facility_status/unlikely",
    "only_contacted" => "facility_status/unknown"
  }.freeze
end
