# frozen_string_literal: true

class FacilitiesCategory < ApplicationRecord
  belongs_to :facility
  belongs_to :facility_category
end
