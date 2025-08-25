# frozen_string_literal: true

class FacilitiesController < BaseControllers::AuthenticateController
  def index
    @facilities = Facility.all
    @facility = Facility.new
  end

  def show
    @facility = Facility.find(params[:id])
  end

  def edit
    @facility = Facility.find(params[:id])
  end

  def create
    @facility = Facility.create!(facility_params)

    redirect_to facilities_path
  end

  def update
    @facility = Facility.find(params[:id])

    if @facility.update(facility_params)
      redirect_to facilities_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def facility_params
    params.expect(facility: [:title, :icon, :facility_category_id])
  end
end
