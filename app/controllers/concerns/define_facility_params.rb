# frozen_string_literal: true

module DefineFacilityParams
  extend ActiveSupport::Concern

  private

  def require_facility_params
    params.require([:space_id, :facility_id, :facility_category_id])
    @space = Space.find(params[:space_id])
    @facility = Facility.find(params[:facility_id])
    @space_facility = SpaceFacility.find_by(space: @space, facility: @facility)
    @facility_review = FacilityReview.find_or_initialize_by(facility: @facility, space: @space, user: current_user)
  end

  def set_space
    @space = Space.find(params[:space_id])
  end

  def set_facility
    @facility = Facility.find(params[:facility_id])
  end

  def set_space_facility
    @space_facility = SpaceFacility.find_by(space: @space, facility: @facility)
  end

  def set_facility_review
    @facility_review = FacilityReview.find_or_initialize_by(facility: @facility, space: @space, user: current_user)
  end

  def set_experiences
    @experiences = FacilityReview::LIST_EXPERIENCES
  end

  def set_category
    @category = if params[:facility_category_id].present?
                  FacilityCategory.find(params[:facility_category_id])
                else
                  Facility.find(params[:facility_id]).facility_categories.first
                end
  end
end
