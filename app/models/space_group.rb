# frozen_string_literal: true

class SpaceGroup < ApplicationRecord
  has_paper_trail

  has_rich_text :how_to_book
  has_rich_text :pricing
  has_rich_text :who_can_use
  has_rich_text :terms

  has_rich_text :about

  has_many :spaces, dependent: :nullify
  has_many :space_contacts, dependent: :nullify

  validates :title, presence: true
end
