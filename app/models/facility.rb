# frozen_string_literal: true

class Facility < ApplicationRecord
  has_many :facilities_categories, dependent: :destroy
  has_many :facility_categories, through: :facilities_categories
end
