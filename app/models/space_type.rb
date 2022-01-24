# frozen_string_literal: true

class SpaceType < ApplicationRecord
  has_many :space_types_relation, dependent: :destroy
  has_many :spaces, through: :space_types_relation, dependent: :destroy
end
