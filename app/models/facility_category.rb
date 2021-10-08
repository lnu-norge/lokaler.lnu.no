# frozen_string_literal: true

class FacilityCategory < ApplicationRecord
  has_many :facilities, dependent: :restrict_with_exception
end
