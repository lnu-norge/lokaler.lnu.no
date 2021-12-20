# frozen_string_literal: true

module SpacesHelper
  def edit_field(partial, form)
    render partial: "spaces/edit/#{partial}", locals: { form: form }
  end

  def inline_editable(field, title_tag = :h2, title_text = Space.human_attribute_name(field), &block)
    render partial: "spaces/edit/common/editable_inline", locals: {
      field: field,
      title_tag: title_tag,
      title_text: title_text,
      block: block
    }
  end

  def render_space_and_group_field(space, field)
    group = space.space_group
    # Setting the fields only if they are available (respond_to) and they have any content (present?)
    field_in_space = (space.public_send(field) if space.respond_to?(field) && space.public_send(field).present?)
    field_in_space_group = (group.public_send(field) if group.respond_to?(field) && group.public_send(field).present?)

    render partial: "spaces/show/common/render_space_and_group_field", locals: {
      field_in_space: field_in_space,
      field_in_space_group: field_in_space_group
    }
  end

  # Generates a static image of a map with a pin, based on
  # the location of a given Space,
  #
  # You can set one or all of :zoom, :height or :width to
  # change properties of the generated image
  #
  # For example like this:
  # static_map_of @space, zoom: 9, height: 800
  #
  # Can also be combined with HTML attributes for the iamge tag
  # static_map_of @space, zoom: 4, class: "p-4"
  def static_map_of(space, zoom: 12, height: 250, width: 400, **html_options)
    unless space.address&.present?
      return static_map_placeholder(height: height, width: width,
                                    html_options: html_options)
    end

    static_map_of_lat_lng(
      lat: space.lat,
      lng: space.lng,
      zoom: zoom,
      height: height,
      width: width,
      html_options: html_options
    )
  end

  def static_map_of_lat_lng(lat:, lng:, zoom: 12, height: 250, width: 400, **html_options) # rubocop:disable Metrics/ParameterLists
    return static_map_did_not_find(height: height, width: width, html_options: html_options) if lat.nil? || lng.nil?

    color_of_pin = "db2777" # Tailwind pink-600
    static_map_image_url = [
      "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static",
      "/pin-l-circle+#{color_of_pin}(#{lng},#{lat})", # Type, color, and position of pin
      "/#{lng},#{lat},#{zoom}", # Position of map
      "/#{width}x#{height}", # Size of map
      "?logo=false", # Hide mapbox logo
      "&@2x", # Render at 2x for retina
      "&access_token=#{ENV['MAPBOX_API_KEY']}"
    ].join
    image_tag static_map_image_url, html_options
  end

  # Used before the space has any information at all
  def static_map_placeholder(height: 250, width: 400, **html_options)
    tag.div(style: "height: #{height}px; max-width: #{width}px",
            class: "bg-gray-100 border border-gray-200 text-gray-400 flex justify-center items-center text-center",
            **html_options) do
      concat inline_svg_tag("place", class: "text-gray-400")
      concat t("address_search.no_address_given")
    end
  end

  # Used if the information given doesn't result in a valid lat lng
  def static_map_did_not_find(height: 250, width: 400, **html_options)
    tag.div(
      t("address_search.didnt_find"),
      style: "height: #{height}px; max-width: #{width}px",
      class: "bg-gray-100 border border-gray-200 flex justify-center items-center text-center",
      **html_options
    )
  end

  # Generates a link to an external map (Google maps, for example)
  # for the current @space
  #
  # Can also be combined with HTML attributes for the link_to tag
  # link_to_external_map_for @space, class: "hover:text-lg"
  def link_to_external_map_for(space, **html_options, &block)
    external_map_url = %W[
      https://www.google.com/maps?q=
      #{ERB::Util.url_encode(
        "#{space.title}, #{space.address}, #{space.post_number} #{space.post_address}"
      )}
    ].join
    link_to external_map_url, **html_options do
      yield block
    end
  end
end
