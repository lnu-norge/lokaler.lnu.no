# frozen_string_literal: true

class AggregatedFacilityReview < ApplicationRecord
  enum experience: { unknown: 0, impossible: 1, unlikely: 2, maybe: 3, likely: 4 }
  belongs_to :facility
  belongs_to :space

  ALLOW_FACILITY_LISTING = %i[maybe likely].freeze # + :unknown,
  scope :has_it, -> { where(experience: ALLOW_FACILITY_LISTING) }
end
