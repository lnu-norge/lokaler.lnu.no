# frozen_string_literal: true

class SpaceFacility < ApplicationRecord
  enum experience: { unknown: 0, impossible: 1, unlikely: 2, maybe: 3, likely: 4 }

  belongs_to :facility
  belongs_to :space
  validates :space, uniqueness: { scope: [:facility] }

  scope :impossible, -> { where(experience: :impossible) }
  scope :not_impossible, -> { where.not(experience: :impossible) }
  scope :in_category, lambda { |facility_category_id|
    joins(:facility).where("facility.facility_category_id": facility_category_id)
  }
  scope :relevant, -> { where(relevant: true) }
  scope :not_relevant, -> { where(relevant: false) }

  def relevant!
    update!(relevant: true)
  end

  def not_relevant!
    update!(relevant: false)
  end

  def not_relevant?
    !relevant?
  end

  def user_review(user)
    FacilityReview.find_or_initialize_by(
      user:,
      facility:,
      space:
    )
  end
end

# == Schema Information
#
# Table name: space_facilities
#
#  id          :bigint           not null, primary key
#  description :string
#  experience  :integer
#  relevant    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  facility_id :bigint           not null
#  space_id    :bigint           not null
#
# Indexes
#
#  index_space_facilities_on_facility_id               (facility_id)
#  index_space_facilities_on_space_id                  (space_id)
#  index_space_facilities_on_space_id_and_facility_id  (space_id,facility_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (space_id => spaces.id)
#
