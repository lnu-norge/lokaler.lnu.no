# frozen_string_literal: true

class Review < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :space
  belongs_to :organization

  has_many :facility_reviews, dependent: :destroy
  accepts_nested_attributes_for :facility_reviews,
                                reject_if: proc { |attributes| attributes['experience'] == 'unknown' }

  enum how_much: { custom_how_much: 0, whole_space: 1, one_room: 2 }
  enum how_long: { custom_how_long: 0, one_weekend: 1, one_evening: 2 }

  validates :star_rating, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true
  validates :organization, presence: true

  after_save { space.aggregate_star_rating }
  after_destroy { space.aggregate_star_rating }
end
