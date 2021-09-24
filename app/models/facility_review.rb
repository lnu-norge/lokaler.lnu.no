# frozen_string_literal: true

class FacilityReview < ApplicationRecord
  enum experience: { was_allowed: 0, was_allowed_but_bad: 1, was_not_allowed: 2, was_not_available: 3 }

  belongs_to :facility
  belongs_to :space
  belongs_to :user
  belongs_to :review, optional: true

  after_save { space.aggregate_facility_reviews }
  after_destroy { space.aggregate_facility_reviews }
end
