# frozen_string_literal: true

class SpaceOwner < ApplicationRecord
  has_many :spaces, dependent: :restrict_with_exception
end
