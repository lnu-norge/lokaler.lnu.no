# frozen_string_literal: true

# rubocop:disable all

def filter_schools(schools)
  foul_titles = [
    /voksenopplæring/i,
    /vikarer/i,
    /fellestjeneste/i
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

def space_from(school)
  space_owner = SpaceOwner.find_by space_owner_from(school)
  space_type = SpaceType.find_by(space_types_from(school))
  {
    title: knead_title(get_info(school["title"])),
    address: school["address"]["street"],
    post_number: school["address"]["postnumber"],
    post_address: school["address"]["poststed"],
    lat: school["lat"],
    lng: school["lon"],
    municipality_code: school["kommuneNummer"],
    organization_number: get_meta(school, "organizationalNumber"),
    fits_people: get_meta(school, "pupils"),
    space_owner: space_owner,
    space_type: space_type
  }
end

def space_types_from(school)
  # TODO: Make it possible to have several space types.
  { type_name: get_meta(school, "types")[0] }
end

def space_owner_from(school)
  # TODO: Change Space model so SpaceOwner is OPTIONAL. Not all spaces have a space owner that's relevant to list out.
  return unless school && school["owner"]

  owner = get_info(school["owner"])
  {
    orgnr: owner["organizationNumber"],
    title: owner["title"]
  }
end

def add_space_contacts_from(school, space)
  contacts = school["contacts"].map { |contact| get_info contact }
  contacts.filter! { |contact| contact[:email] || contact[:phone] || contact[:url] }
  contacts.filter! { |contact| contact[:role] || contact[:name] || contact[:url] }
  contacts_parsed = contacts.map do |contact|
    parsed = {
      title: "#{contact[:role]} #{contact[:name]}".strip
    }
    parsed["url"] = contact["url"] if contact["url"]&.present?
    parsed["email"] = contact["email"] if contact["email"]&.present?
    parsed["telephone"] = contact["phone"] if contact["phone"]&.present?
  end
  space.space_contacts.build contacts_parsed
  space
end

def new_unless_exists(model, item)
  model.new(item) unless model.find_by(item)
end

def new_all_unless_exists(model, items)
  new_items = items.reject { |item| model.find_by(item) }
  new_items.map { |item| model.new item }
end

# rubocop:enable all
