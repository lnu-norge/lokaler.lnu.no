# frozen_string_literal: true

class SpacesController < AuthenticateController # rubocop:disable Metrics/ClassLength
  def index
    @spaces = Space.all.order updated_at: :desc
    @space = Space.new
  end

  def show
    @space = Space.includes(:space_contacts).where(id: params[:id]).first
    @space_contact = SpaceContact.new(space_id: @space.id, space_owner_id: @space.space_owner_id)
  end

  def new
    @space = Space.new
  end

  def create
    address_params = get_address_params(params)
    return redirect_to spaces_path, alert: t("address_search.didnt_find") if address_params.nil?

    @space = Space.create!(
      space_owner: SpaceOwner.find_or_create_by!(title: params[:space][:space_owner_title]),
      **space_params,
      **address_params
    )

    redirect_to space_path(@space)
  end

  def address_search
    address = Space.search_for_address(
      address: params[:address],
      post_number: params[:post_number],
      post_address: params[:post_address]
    )

    return render json: { map_image_html: helpers.static_map_of_lat_lng(lat: nil, lng: nil) } if address.nil?

    render json: { **address, map_image_html: helpers.static_map_of_lat_lng(lat: address[:lat], lng: address[:lng]) }
  end

  def edit
    @space = Space.find(params[:id])
  end

  def edit_field
    @space = Space.find(params[:id])
    @field = params[:field]
    render "spaces/edit/common/edit_field"
  end

  def update
    @space = Space.find(params[:id])
    address_params = get_address_params(params)

    unless params[:space][:space_owner_title].nil?
      @space.update!(
        space_owner: SpaceOwner.find_or_create_by!(title: params[:space][:space_owner_title])
      )
    end

    if @space.update(
      **space_params,
      **address_params
    )
      redirect_to space_path(@space)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def upload_image
    @space = Space.find(params[:id])
    @space.images.attach(params[:image])
    @space.save!
    flash[:notice] = t("images.upload_success")
    redirect_to space_path(params[:id])
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

  def spaces_search
    filtered_spaces = filter_spaces(params)
    space_count = filtered_spaces.count
    spaces = filtered_spaces.first(SPACE_SEARCH_PAGE_SIZE)

    markers = spaces.map(&:render_map_marker)

    facility_ids = params[:facilities]&.map(&:to_i) || []
    render json: {
      listing: render_to_string(
        partial: "spaces/index/space_listings", locals: {
          spaces: spaces,
          filtered_facilities: Facility.find(facility_ids),
          space_count: space_count,
          page_size: SPACE_SEARCH_PAGE_SIZE
        }
      ),
      markers: markers
    }
  end

  private

  SPACE_SEARCH_PAGE_SIZE = 20

  def get_address_params(params)
    Space.search_for_address(
      address: params[:space][:address],
      post_number: params[:space][:post_number],
      post_address: params[:space][:post_address]
    ) || {}
  end

  def filter_spaces(params)
    space_types = params[:space_types]&.map(&:to_i)
    facilities = params[:facilities]&.map(&:to_i)

    spaces = Space.includes([:images_attachments, :space_type]).filter_on_location(
      params[:north_west_lat],
      params[:north_west_lng],
      params[:south_east_lat],
      params[:south_east_lng]
    )

    spaces = spaces.filter_on_space_types(space_types) unless space_types.nil?
    spaces = spaces.order("star_rating DESC NULLS LAST")
    spaces = Space.filter_on_facilities(spaces, facilities) unless facilities.nil?
    spaces
  end

  def space_params
    params.require(:space).permit(
      :title,
      :address,
      :lat,
      :lng,
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
      :facility_description,
      space_owner_attributes: %i[id how_to_book pricing terms who_can_use]
    )
  end
end
