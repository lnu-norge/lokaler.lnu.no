# frozen_string_literal: true

class Space < ApplicationRecord
  has_paper_trail
  has_many_attached :images
  has_many :facilities, dependent: :restrict_with_exception
  has_many :facility_reviews, dependent: :restrict_with_exception
  has_many :reviews, dependent: :restrict_with_exception
  has_many :aggregated_facility_reviews, dependent: :restrict_with_exception
  belongs_to :space_owner
  belongs_to :space_type

  def aggregate_facility_reviews
    Spaces::AggregateFacilityReviews.call(space: self)
  end
end
