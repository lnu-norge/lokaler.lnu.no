# frozen_string_literal: true

class SpacesController < ApplicationController
  def index
    @spaces = Space.all
    @space = Space.new
  end

  def show
    @space = Space.find(params[:id])
  end

  def create
    space_type = SpaceType.find_or_create_by!(type_name: 'Skole')
    @space = Space.create!(space_type: space_type, **space_params)

    redirect_to spaces_path
  end

  def edit
    @space = Space.find(params[:id])
  end

  def update
    @space = Space.find(params[:id])

    if @space.update(space_params)
      redirect_to spaces_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def upload_image
    @space = Space.find(params[:id])
    @space.images.attach(params[:image])
    @space.save!
    redirect_to spaces_path
  end

  private

  def space_params
    params.require(:space).permit(:address, :lat, :long, :space_owner_id)
  end
end
