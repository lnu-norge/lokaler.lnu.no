# frozen_string_literal: true

class AggregatedFacilityReview < ApplicationRecord
  enum experience: { unknown: 0, unlikely: 1, maybe: 2, likely: 3 }

  belongs_to :facility
  belongs_to :space
end
