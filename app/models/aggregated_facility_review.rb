# frozen_string_literal: true

class AggregatedFacilityReview < ApplicationRecord
  enum experience: { unknown: 0, impossible: 1, unlikely: 2, maybe: 3, likely: 4 }
  belongs_to :facility
  belongs_to :space

  scope :unknown, -> { where(experience: :unknown) }
  scope :impossible, -> { where(experience: :impossible) }
  scope :neither_unknown_nor_impossible, -> { where.not(experience: [:unknown, :impossible]) } # rubocop:disable Style/SymbolArray
  scope :in_category, lambda { |facility_category_id|
    joins(:facility).where('facility.facility_category_id': facility_category_id)
  }
end
