# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :user
  belongs_to :space

  has_many :facility_reviews, dependent: :destroy

  validates :star_rating, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true

  after_save { space.aggregate_star_rating }
  after_destroy { space.aggregate_star_rating }
end
