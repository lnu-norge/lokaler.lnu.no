# frozen_string_literal: true

class FacilityReview < ApplicationRecord
  belongs_to :facility
  belongs_to :space
  belongs_to :user
  belongs_to :review

  after_save { space.aggregate_facility_reviews }
  after_destroy { space.aggregate_facility_reviews }

  enum experience: { was_allowed: 0, was_allowed_but_bad: 1, was_not_allowed: 2, was_not_available: 3 }

  scope :impossible, -> { where(experience: :was_not_available) }
  scope :positive, -> { where(experience: [:was_allowed, :was_allowed_but_bad]) }
  scope :negative, -> { where(experience: :was_not_allowed) }

  def experience_icon
    case experience
    when "was_allowed"
      :likely
    when "was_allowed_but_bad"
      :maybe
    when "was_not_allowed"
      :unlikely
    when "was_not_available"
      :impossible
    else
      :unknown
    end
  end
end
