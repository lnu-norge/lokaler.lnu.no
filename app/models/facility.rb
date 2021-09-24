# frozen_string_literal: true

class Facility < ApplicationRecord
  belongs_to :space

  after_create { space.aggregate_facility_reviews }
end
