# frozen_string_literal: true

class FacilityReview < ApplicationRecord
  belongs_to :facility
  belongs_to :space
  belongs_to :user

  enum experience: { was_allowed: 0, was_not_allowed: 2, was_not_available: 3 }

  scope :impossible, -> { where(experience: :was_not_available) }
  scope :positive, -> { where(experience: :was_allowed) }
  scope :negative, -> { where(experience: :was_not_allowed) }

  validates :space, uniqueness: { scope: [:user, :facility] }

  after_commit do
    space.aggregate_facility_reviews(facilities: [facility])
  end

  def experience_icon
    ICON_FOR_EXPERIENCE[experience]
  end

  LIST_EXPERIENCES = [
    "unknown",
    *FacilityReview.experiences.keys.reverse
  ].reverse

  ICON_FOR_EXPERIENCE = {
    "was_allowed" => "likely",
    "was_not_allowed" => "unlikely",
    "was_not_available" => "impossible",
    "unknown" => "unknown"
  }.freeze
end

# == Schema Information
#
# Table name: facility_reviews
#
#  id          :bigint           not null, primary key
#  experience  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  facility_id :bigint           not null
#  space_id    :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_facility_reviews_on_facility_id                           (facility_id)
#  index_facility_reviews_on_space_id                              (space_id)
#  index_facility_reviews_on_space_id_and_facility_id              (space_id,facility_id)
#  index_facility_reviews_on_space_id_and_user_id_and_facility_id  (space_id,user_id,facility_id) UNIQUE
#  index_facility_reviews_on_user_id                               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
