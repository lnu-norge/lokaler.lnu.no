# frozen_string_literal: true

class FacilityReview < ApplicationRecord
  belongs_to :facility
  belongs_to :space
  belongs_to :user
  belongs_to :review

  after_save { space.aggregate_facility_reviews }
  after_destroy { space.aggregate_facility_reviews }

  enum experience: { was_allowed: 0, was_allowed_but_bad: 1, was_not_allowed: 2, was_not_available: 3 }

  def experience_icon
    case experience
    when 'was_allowed'
      :likely
    when 'was_allowed_but_bad'
      :maybe
    when 'was_not_allowed'
      :unlikely
    when 'was_not_available'
      :impossible
    else
      :unknown
    end
  end

  def experience_tooltip
    case experience
    when 'was_allowed'
      'Fikk lov'
    when 'was_allowed_but_bad'
      'Fikk lov, men dårlig opplevelse'
    when 'was_not_allowed'
      'Fikk ikke lov'
    when 'was_not_available'
      'De har ikke'
    else
      'Ikke spurt'
    end
  end
end
