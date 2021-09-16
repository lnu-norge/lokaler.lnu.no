# frozen_string_literal: true

class FacilitiesController < ApplicationController
  def index
    @facilities = Facility.all
    @facility = Facility.new
  end

  def show
    @facility = Facility.find(params[:id])
  end

  def create
    @facility = Facility.new(facility_params)

    if @facility.save
      redirect_to facilities_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @facility = Facility.find(params[:id])
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
    params.require(:facility).permit(:title, :space_id)
  end
end
