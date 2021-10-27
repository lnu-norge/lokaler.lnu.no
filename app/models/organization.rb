# frozen_string_literal: true

class Organization < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :reviews, dependent: :restrict_with_exception

  validates :name, presence: true
end
