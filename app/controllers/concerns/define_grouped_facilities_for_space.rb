# frozen_string_literal: true

module DefineGroupedFacilitiesForSpace
  extend ActiveSupport::Concern

  private

  def define_facilities
    @grouped_relevant_facilities = @space.relevant_space_facilities(grouped: true, user: current_user)
    @non_relevant_facilities = @space.non_relevant_space_facilities
    @grouped_non_relevant_facilities = @space.group_space_facilities(ungrouped_facilities: @non_relevant_facilities,
                                                                     user: current_user)
    @experiences = FacilityReview::LIST_EXPERIENCES
  end
end
