# frozen_string_literal: true

school_space_types = [
  {
    type_name: "Grunnskole",
    related_facilities_by_title: [
      "Klasserom",
      "Gymsal",
      "Sove på gulvet",
      "Kjøkken med ovn",
      "Rullestolvennlig inngang",
      "Rullestolvennlig inne",
      "HC-toalett",
      "Wifi",
      "Lov å spise medbrakt",
      "Nær kollektiv",
      "Parkering"
    ]
  },
  {
    type_name: "VGS",
    related_facilities_by_title: [
      "Klasserom",
      "Gymsal",
      "Sove på gulvet",
      "Kjøkken med ovn",
      "Rullestolvennlig inngang",
      "Rullestolvennlig inne",
      "HC-toalett",
      "Wifi",
      "Prosjektor",
      "Nær kollektiv",
      "Parkering"
    ]
  }
]

# Create the school space types
school_space_types.each do |type|
  SpaceType.find_or_create_by(type_name: type[:type_name]) do |space_type|
    type[:related_facilities_by_title].each do |facility_title|
      space_type.facilities << Facility.find_by!(title: facility_title)
    end
  end
end

# And the non-school space types
SpaceType.find_or_create_by(type_name: "Bibliotek") do |space_type|
  space_type.facilities = [
    Facility.find_by(title: "Møterom"),
    Facility.find_by(title: "Wifi"),
    Facility.find_by(title: "Prosjektor"),
    Facility.find_by(title: "Kopimaskin / skriver"),
    Facility.find_by(title: "Makerspace"),
    Facility.find_by(title: "Lov å spise medbrakt"),
    Facility.find_by(title: "Kaffemaskin / vannkoker"),
    Facility.find_by(title: "Rullestolvennlig inngang"),
    Facility.find_by(title: "Rullestolvennlig inne"),
    Facility.find_by(title: "HC-toalett")
  ]
end
SpaceType.find_or_create_by(type_name: "Folkehøgskole") do |space_type|
  space_type.facilities = [
    Facility.find_by(title: "Auditorium"),
    Facility.find_by(title: "Gymsal"),
    Facility.find_by(title: "Klasserom"),
    Facility.find_by(title: "Wifi"),
    Facility.find_by(title: "Prosjektor"),
    Facility.find_by(title: "Kopimaskin / skriver"),
    Facility.find_by(title: "Sove på gulvet"),
    Facility.find_by(title: "Senger"),
    Facility.find_by(title: "Lov å spise medbrakt"),
    Facility.find_by(title: "Kjøkken med ovn"),
    Facility.find_by(title: "Kjøleskap"),
    Facility.find_by(title: "Strømuttak"),
    Facility.find_by(title: "Høytaleranlegg"),
    Facility.find_by(title: "Mikrofon"),
    Facility.find_by(title: "Lysanlegg"),
    Facility.find_by(title: "Mixebrett"),
    Facility.find_by(title: "Kaffemaskin / vannkoker"),
    Facility.find_by(title: "Rullestolvennlig inngang"),
    Facility.find_by(title: "Rullestolvennlig inne"),
    Facility.find_by(title: "HC-toalett")
  ]
end
