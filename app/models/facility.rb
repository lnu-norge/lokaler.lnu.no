# frozen_string_literal: true

class Facility < ApplicationRecord
  belongs_to :facility_category

  def category
    facility_category.title
  end
end
