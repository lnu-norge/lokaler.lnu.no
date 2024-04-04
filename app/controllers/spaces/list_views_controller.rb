# frozen_string_literal: true

module Spaces
  class ListViewsController < BaseControllers::AuthenticateController
    include FilterableSpaces
    def index
      filter_spaces
    end
  end
end
