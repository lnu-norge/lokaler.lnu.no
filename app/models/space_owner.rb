# frozen_string_literal: true

class SpaceOwner < ApplicationRecord
  has_paper_trail

  has_rich_text :how_to_book
  has_rich_text :pricing
  has_rich_text :who_can_use
  has_rich_text :terms

  has_rich_text :about

  has_many :spaces, dependent: :restrict_with_exception
  has_many :space_contacts, dependent: :restrict_with_exception
end
