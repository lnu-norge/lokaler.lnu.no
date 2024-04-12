# frozen_string_literal: true

module Spaces
  class ListViewsController < BaseControllers::AuthenticateController
    include FilterableSpaces
    def index
      filter_spaces

      @spaces = @spaces.limit(10)
    end
  end
end
