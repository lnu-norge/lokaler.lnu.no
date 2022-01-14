# frozen_string_literal: true

# rubocop:disable all

def filter_schools(schools)
  foul_titles = [
    /voksenoppl/i,
    /vikarer/i,
    /fellestjeneste/i,
    /spesial tiltak/i,
    /Vestfold og Telemark fylkeskommune/ # For some reason, the administration itself is added to NSR...
  ]
  # Remove any schools we do not care for
  schools.reject! do |school|
    foul_titles.any? { |pattern| pattern.match? get_info(school["title"]) }
  end
end

def get_meta(school, field)
  fields = {}
  school["meta"].each do |item|
    fields = fields.merge get_info(item)
  end
  fields[field]
end

def get_info(info)
  return info["info"] if info["info"]

  info
end

def knead_title(title)
  title.sub! /vid.regå.nde sk.le/i, "VGS"
  title.sub! /vid.regå.nde privatsk.le/i, "privat VGS"
  title.sub! /vid.regå.nde/i, "VGS"
  title
end

def validate_lat_long(school)
  # p "Validating address for school  lat: #{school["lat"]}, lon: #{school["lon"]}"
  return {
    lat: school["lat"],
    lng: school["lon"],
    municipality_code: school["kommuneNummer"]
  } unless !school["lat"] || school["lat"] == 0
  return nil unless school["address"]["street"] # We need the street, else we get too many false matches.
  begin
    # If lat lon is not set from NSR school, then we have to set it ourselves:
    # p "Looking up address for school lat: #{school["lat"]}, lon: #{school["lon"]}"
    results = Spaces::LocationSearchService.call(
      address: school["address"]["street"],
      post_number: school["address"]["postnumber"],
      post_address: school["address"]["poststed"]
    )
  rescue
    # Any erros, skip this space:
    return nil
  else
    return nil if results.empty?
    return results.first
  end
end

def validate_address(school)
  address = school["address"]["street"]
  return nil unless address.present?

  address
end

def space_from(school)
  space_group = SpaceGroup.find_by space_group_from(school)
  space_type = SpaceType.find_by(space_types_from(school))

  address = validate_address(school)
  return unless address

  position = validate_lat_long(school)
  return unless position

  {
    title: knead_title(get_info(school["title"])),
    address: address,
    post_number: school["address"]["postnumber"],
    post_address: school["address"]["poststed"],
    lat: position[:lat],
    lng: position[:lng],
    municipality_code: position[:municipality_code],
    organization_number: get_meta(school, "organizationalNumber"),
    space_group: space_group,
    space_type: space_type
  }
end

def space_types_from(school)
  # TODO: Make it possible to have several space types.
  { type_name: get_meta(school, "types")[0] }
end

def space_group_from(school)
  # TODO: Change Space model so SpaceGroup is OPTIONAL
  # Not all spaces have a space group that's relevant to list out.
  return unless school && school["owner"]

  owner = get_info(school["owner"])
  type = get_meta(school, "types")[0]

  if type == "vgs"
    return  {
      title: "VGS eid av #{owner["title"]}"
    }
  end

  {
    title: "Grunnskoler eid av #{owner["title"]}"
  }
end

def get_valid_url(url)
  return nil unless url&.present?
  begin
    uri = Addressable::URI.parse(url)
    url = "http://#{url}" unless !uri ||  uri.blank? || uri.scheme
    # Try to parse again, we might get an error now:
    Addressable::URI.parse(url)
    return url
  rescue Addressable::URI::InvalidURIError
    return nil
  end
end

def space_contacts_from(school)
  contacts = school["contacts"]&.map { |contact| get_info contact }
  return unless contacts
  contacts = contacts.filter { |contact| contact["email"].present? || contact["phone"].present? || contact["url"].present? }
  contacts = contacts.filter { |contact| contact["role"].present? || contact["name"].present? }
  contacts = contacts.map do |contact|
    parsed = {
      title: "#{contact["role"]} #{contact["name"]}".strip
    }

    url = get_valid_url(contact["url"])
    parsed["url"] = url if url&.present?
    parsed["email"] = contact["email"] if contact["email"]&.present?
    parsed["telephone"] = contact["phone"] if contact["phone"]&.present?
    parsed
  end
  contacts
end

def new_unless_exists(model, item)
  model.new(item) unless model.find_by(item)
end

def new_all_unless_exists(model, items)
  new_items = items.reject { |item| model.find_by(item) }
  new_items.map { |item| model.new item }
end

# rubocop:enable all
