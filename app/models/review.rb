# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :user
  belongs_to :space

  validates :star_rating, presence: true

  after_save { space.aggregate_star_rating }
end
