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
      result = find_duplicates
      return [] if result.nil?

      result
    end

    def find_duplicates
      []
    end
  end
end
