# frozen_string_literal: true

class SpacesController < AuthenticateController
  include SpacesConcern

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

    redirect_to space_path(@space)
  end

  def edit
    @space = Space.find(params[:id])
  end

  def edit_field
    @space = Space.find(params[:id])
    @field = params[:field]
    render 'spaces/edit/common/edit_field'
  end

  def update
    @space = Space.find(params[:id])

    if @space.update(space_params)
      redirect_to space_path(@space)
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

  def rect_for_spaces
    spaces_in_rect = Space.rect_of_spaces

    # We add a padding of 0.02 degrees here so the spaces close to the corners do not get clipped out
    render json: {
      northEast: {
        lat: spaces_in_rect[:north_east][:lat] + 0.02,
        lng: spaces_in_rect[:north_east][:lng] + 0.02
      },
      southWest: {
        lat: spaces_in_rect[:south_west][:lat] - 0.02,
        lng: spaces_in_rect[:south_west][:lng] - 0.02
      }
    }
  end

  def spaces_search # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    space_types = params[:space_types]
    facilities = params[:facilities]

    spaces = Space.where(
      ':north_west_lat >= lat AND :north_west_lng <= lng AND :south_east_lat <= lat AND :south_east_lng >= lng',
      north_west_lat: params[:north_west_lat],
      north_west_lng: params[:north_west_lng],
      south_east_lat: params[:south_east_lat],
      south_east_lng: params[:south_east_lng]
    )

    spaces = spaces.filter_on_space_types(space_types) unless space_types.nil?
    spaces = filter_on_facilities(spaces, facilities) unless facilities.nil?

    # Only show the 20 best matches on the map
    spaces = spaces.first(20)

    markers = spaces.map do |space|
      html = render_to_string partial: 'spaces/index/map_marker', locals: { space: space }
      {
        lat: space.lat,
        lng: space.lng,
        id: space.id,
        html: html
      }
    end

    render json: {
      listing: render_to_string(
        partial: 'spaces/index/space_listings', locals: { spaces: spaces.first(10) }
      ),
      markers: markers
    }
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
      :more_info,
      space_owner_attributes: %i[id how_to_book pricing terms who_can_use]
    )
  end
end
