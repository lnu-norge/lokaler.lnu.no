# frozen_string_literal: true

class FacilityReview < ApplicationRecord
  belongs_to :facility
  belongs_to :space
  belongs_to :user
  belongs_to :review

  enum experience: { was_allowed: 0, was_not_allowed: 2, was_not_available: 3 }

  scope :impossible, -> { where(experience: :was_not_available) }
  scope :positive, -> { where(experience: :was_allowed) }
  scope :negative, -> { where(experience: :was_not_allowed) }

  validates :facility, uniqueness: { scope: :review }

  def experience_icon
    ICON_FOR_EXPERIENCE[experience]
  end

  ICON_FOR_EXPERIENCE = {
    "was_allowed" => "likely",
    "was_not_allowed" => "unlikely",
    "was_not_available" => "impossible",
    "unknown" => "unknown"
  }.freeze
end
