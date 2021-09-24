# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :user
  belongs_to :space

  validates :star_rating, presence: true, numericality: { greater_than: 0, less_than: 6 }

  after_save { space.aggregate_star_rating }
  after_destroy { space.aggregate_star_rating }
end
