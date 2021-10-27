# frozen_string_literal: true

class SpaceContact < ApplicationRecord
  belongs_to :space, optional: true
  belongs_to :space_owner
end
