# frozen_string_literal: true

module FilterableBySpaceTypes
  extend ActiveSupport::Concern

  private

  def set_filterable_space_types
    @filterable_space_types = SpaceType.all
  end

  def filter_by_space_types
    return @filtered_spaces if params[:space_types].blank?

    space_types = params[:space_types]&.map(&:to_i)
    @filtered_space_types = SpaceType.find(space_types)
    @filtered_spaces.filter_on_space_types(space_types)
  end
end
