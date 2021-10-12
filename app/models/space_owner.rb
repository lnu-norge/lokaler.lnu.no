# frozen_string_literal: true

class SpaceOwner < ApplicationRecord
  has_paper_trail

  has_rich_text :how_to_book
  has_rich_text :about

  has_many :spaces, dependent: :restrict_with_exception
end
