# frozen_string_literal: true

class SpaceTypesRelation < ApplicationRecord
  belongs_to :space_type
  belongs_to :space
end
