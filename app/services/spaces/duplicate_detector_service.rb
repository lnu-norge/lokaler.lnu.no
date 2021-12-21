# frozen_string_literal: true

module Spaces
  class DuplicateDetectorService < ApplicationService
    def initialize(space)
      @title = space.title
      @address = space.address
      @post_number = space.post_number
      super()
    end

    def call
      potential_duplicates = find_potential_duplicates
      return potential_duplicates if potential_duplicates.present?

      nil
    end

    private

    attr_reader :title, :address, :post_number

    def find_potential_duplicates
      duplicates = []

      # If any full matches, just return those first:
      duplicates << full_match
      return duplicates.flatten if duplicates[0].present?

      # If any matches by full address, return those without checking further:
      duplicates << by_full_address
      return duplicates.flatten.compact if duplicates[0].present?

      # Then return any matches by title and/or post
      duplicates << by_post_and_title
      duplicates.flatten.compact.uniq
    end

    def full_match
      return nil unless title.present? && address.present? && post_number.present?

      Space.where(
        "title ILIKE ?", "%#{title}%"
      ).where({
                address: address,
                post_number: post_number
              })
    end

    def by_post_and_title
      return nil unless title.present? && post_number.present?

      Space.where(
        "title ILIKE ?", "%#{title}%"
      ).where({
                post_number: post_number
              })
    end

    def by_full_address
      return nil unless address.present? && post_number.present?

      Space.where({
                    address: address,
                    post_number: post_number
                  })
    end
  end
end
