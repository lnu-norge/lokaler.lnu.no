# frozen_string_literal: true

class SpacesController < BaseControllers::AuthenticateController # rubocop:disable Metrics/ClassLength
  include DefineGroupedFacilitiesForSpace
  include FilterableSpaces
  include AccessibleActivePersonalSpaceList

  before_action :access_active_personal_list, only: %i[index show spaces_search]

  def index
    params_for_search

    set_filterable_facility_categories
    set_filterable_space_types
    filter_spaces

    @space_count = @spaces.to_a.size
    @page_size = SPACE_SEARCH_PAGE_SIZE
    @spaces = @spaces.limit(@page_size)
  end

  def show
    @space = Space.includes(:space_contacts).where(id: params[:id]).first

    define_facilities
  end

  def new
    @space = Space.new
  end

  def edit
    @space = Space.find(params[:id])
  end

  def create # rubocop:disable Metrics/AbcSize
    address_params = get_address_params(params)
    return redirect_to spaces_path, alert: t("address_search.didnt_find") if address_params.nil?

    @space = Space.new(
      **space_params,
      **address_params
    )

    if params[:space][:space_group_title].present?
      @space.space_group = SpaceGroup.find_or_create_by!(title: params[:space][:space_group_title])
    end

    if @space.save
      redirect_to space_path(@space)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @space = Space.find(params[:id])
    address_params = get_address_params(params)

    space_group_from(params)

    if @space.update(
      **space_params,
      **address_params
    )
      redirect_to space_path(@space)
    else
      @field = "basics"
      render "spaces/edit/common/edit_field"
    end
  end

  def address_search
    address = Space.search_for_address(
      address: params[:address],
      post_number: params[:post_number]
    )

    return render json: { map_image_html: helpers.static_map_of_lat_lng(lat: nil, lng: nil) } if address.nil?

    render json: { **address, map_image_html: helpers.static_map_of_lat_lng(lat: address[:lat], lng: address[:lng]) }
  end

  def edit_field
    @space = Space.find(params[:id])
    @field = params[:field]
    render "spaces/edit/common/edit_field"
  end

  def space_group_from(params)
    if params[:space][:space_group_title].present?
      @space.update!(
        space_group: SpaceGroup.find_or_create_by!(title: params[:space][:space_group_title])
      )
    elsif params[:space][:space_group_title] == ""
      @space.update!(space_group: nil)
    end
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
    filter_spaces
    @space_count = @spaces.to_a.size
    @spaces = @spaces.limit(SPACE_SEARCH_PAGE_SIZE)

    render_listing_and_markers_json
  end

  def check_duplicates
    duplicates = duplicates_from_params

    if duplicates.blank?
      return render json: {
        html: nil,
        count: 0
      }
    end

    render json: {
      html: render_to_string(
        partial: "spaces/new/space_duplicate_list", locals: {
          spaces: duplicates
        }
      ),
      count: duplicates.size
    }
  end

  def fullscreen_images
    @space = Space.find(params[:id])
    @start_at = params[:start] || 0
    render "spaces/show/image_header_fullscreen"
  end

  private

  SPACE_SEARCH_PAGE_SIZE = 20

  def render_listing_and_markers_json
    view_as = params[:view_as]

    render json: {
      listing: get_listing_json_for_view(view_as),
      markers: get_marker_json_for_view(view_as)
    }
  end

  def get_listing_json_for_view(view_as)
    @experiences = FacilityReview::LIST_EXPERIENCES

    facility_ids = params[:facilities]&.map(&:to_i) || []
    @filtered_facilities = Facility.includes(:facility_categories).find(facility_ids)
    @non_filtered_facilities = Facility.includes(:facility_categories).where.not(id: facility_ids)

    spaces = preload_spaces_data_for_view(view_as)

    @page_size = SPACE_SEARCH_PAGE_SIZE
    render_to_string(
      partial: "spaces/index/space_listings", locals: {
        spaces:,
        space_count: @space_count,
        view_as:,
        page_size: @page_size
      }
    )
  end

  def get_marker_json_for_view(view_as)
    return [] unless view_as == "map"

    @spaces.map(&:render_map_marker)
  end

  def preload_spaces_data_for_view(view_as)
    # Fresh query to get all the data for the filtered and ordered spaces, without
    # the need to include all this data while filtering

    if view_as == "table"
      Space
        .includes_data_for_show
        .find(@spaces.map(&:id)) # This keeps the order of the spaces
    else
      Space
        .includes_data_for_filter_list
        .find(@spaces.map(&:id)) # This keeps the order of the spaces
    end
  end

  def duplicates_from_params
    test_space = Space.new(
      title: params[:title],
      address: params[:address],
      post_number: params[:post_number]
    )
    duplicates = test_space.potential_duplicates
    test_space.delete
    duplicates
  end

  def get_address_params(params)
    Space.search_for_address(
      address: params[:space][:address],
      post_number: params[:space][:post_number]
    ) || {}
  end

  def params_for_search
    params.permit(
      :search_for_title
    )
  end

  def space_params # rubocop:disable  Metrics/MethodLength
    params.require(:space).permit(
      :title,
      :address,
      :lat,
      :lng,
      :location_description,
      { space_type_ids: [] },
      :space_group_id,
      :post_number,
      :post_address,
      :municipality_code,
      :organization_number,
      :how_to_book,
      :who_can_use,
      :pricing,
      :terms,
      :more_info,
      :facility_description,
      :url,
      space_group_attributes: %i[id how_to_book pricing terms who_can_use]
    )
  end
end
