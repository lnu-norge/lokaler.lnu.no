# frozen_string_literal: true

module Spaces
  class DuplicateDetectorService < ApplicationService
    def initialize(space)
      @title = space.title
      @address = space.address
      @post_number = space.post_number
      @post_address = space.post_address
      super()
    end

    def call
      potential_duplicates = find_potential_duplicates
      return potential_duplicates if potential_duplicates.present?

      nil
    end

    def find_potential_duplicates
      duplicates = []
      duplicates << Space.find_by(title: @title) if @title.present?
      duplicates << Space.find_by(full_address) if full_address.present?
      duplicates.compact
    end

    def full_address
      return nil unless @address.present? && @post_number.present? && @post_address.present?

      {
        address: @address,
        post_number: @post_number,
        post_address: @post_address
      }
    end
  end
end
