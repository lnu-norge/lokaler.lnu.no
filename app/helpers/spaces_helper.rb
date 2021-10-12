# frozen_string_literal: true

module SpacesHelper
  def edit_field(partial, form)
    render partial: "spaces/edit/#{partial}", locals: { form: form }
  end

  def inline_editable(field, title_tag = :h2, title_text = Space.human_attribute_name(field), &block)
    render partial: 'spaces/edit/editable_inline', locals: {
      field: field,
      title_tag: title_tag,
      title_text: title_text,
      block: block
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
    color_of_pin = 'db2777' # Tailwind pink-600
    static_map_image_url = [
      'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static',
      "/pin-l-circle+#{color_of_pin}(#{space.lng},#{space.lat})", # Type, color, and position of pin
      "/#{space.lng},#{space.lat},#{zoom}", # Position of map
      "/#{width}x#{height}", # Size of map
      '?logo=false', # Hide mapbox logo
      '&@2x', # Render at 2x for retina
      "&access_token=#{ENV['MAPBOX_API_KEY']}"
    ].join
    image_tag static_map_image_url, html_options
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
