# frozen_string_literal: true

class SpacesController < ApplicationController
  def index
    @spaces = Space.all.order updated_at: :desc
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

  def spaces_in_rect
    spaces = Space.where(
      ':north_west_lat >= lat AND :north_west_lng <= lng AND :south_east_lat <= lat AND :south_east_lng >= lng',
      north_west_lat: params[:north_west_lat],
      north_west_lng: params[:north_west_lng],
      south_east_lat: params[:south_east_lat],
      south_east_lng: params[:south_east_lng]
    )

    response = spaces.map do |space|
      {
        lat: space.lat,
        lng: space.lng,
        id: space.id,
        title: space.title,
        starRating: space.star_rating,
        url: space_url(space)
      }
    end

    render json: response
  end

  private

  def space_params
    params.require(:space).permit(
      :title,
      :address,
      :lat,
      :lng,
      :space_owner_id,
      :space_type_id,
      :post_number,
      :post_address,
      :municipality_code,
      :organization_number,
      :fits_people,
      :how_to_book,
      :who_can_use,
      :pricing,
      :terms,
      :more_info
    )
  end
end
