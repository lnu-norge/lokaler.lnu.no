# frozen_string_literal: true

# rubocop:disable all

require "json"
require "set"
require "./db/seeds/imports/nsr/helpers"

def import_spaces_from_nsr_schools
  # Counts
  count_stats(info: "Before import from NSR JSON:")

  # Load json file
  file = File.read(Rails.root.join("db", "seeds", "imports", "nsr", "nsrParsedSchools.json"))
  data = filter_schools(JSON.parse(file))

  p raw_schools_to_parse: data.length

  # Set up and save SpaceTypes
  space_type_data = [
    {
      type_name: "barneskole",
      related_facilities_by_title: %w[
        Klasserom
        Gymsal
        Sove på gulvet
        Kjøkken med ovn
        Rullestolvennlig inngang
        Rullestolvennlig inne
        HC-toalett
        Wifi
        Lov å spise medbrakt
        Nær kollektiv
        Parkering
      ]
    },
    {
      type_name: "ungdomsskole",
      related_facilities_by_title: %w[
        Klasserom
        Gymsal
        Sove på gulvet
        Kjøkken med ovn
        Rullestolvennlig inngang
        Rullestolvennlig inne
        HC-toalett
        Wifi
        Lov å spise medbrakt
        Nær kollektiv
        Parkering
      ]
    },
    {
      type_name: "grunnskole",
      related_facilities_by_title: %w[
        Klasserom
        Gymsal
        Sove på gulvet
        Kjøkken med ovn
        Rullestolvennlig inngang
        Rullestolvennlig inne
        HC-toalett
        Wifi
        Lov å spise medbrakt
        Nær kollektiv
        Parkering
      ]
    },
    {
      type_name: "vgs",
      related_facilities_by_title: %w[
        Klasserom
        Gymsal
        Sove på gulvet
        Rullestolvennlig inngang
        Rullestolvennlig inne
        HC-toalett
        Wifi
        Prosjektor
        Nær kollektiv
        Parkering
      ]
    }
  ]
  space_types = space_type_data.map do |data|
    {
      type_name: data[:type_name]
    }
  end
  # TODO: Set up facility relations?
  p "importing #{space_types.length} space types"
  SpaceType.import new_all_unless_exists(SpaceType, space_types)

  space_types_facility_relations = space_type_data.map do |data|
    space_type = SpaceType.find_by(type_name: data[:type_name])

    data[:related_facilities_by_title].map do |facility_title|
      {
        space_type:,
        facility: Facility.find_by(title: facility_title)
      }
    end
  end.flatten
  SpaceTypesFacility.import new_all_unless_exists(SpaceTypesFacility, space_types_facility_relations)

  # Trawl through it, and extract information into Rails format

  # Set up owners first:
  space_groups = Set[]
  data.each do |school|
    space_groups << space_group_from(school)
  end
  # Save them
  p "importing #{space_groups.length} space groups"
  SpaceGroup.import new_all_unless_exists(SpaceGroup, space_groups)

  # Then start parsing Spaces, as they depend on the above
  spaces = []
  space_contacts = []
  space_type_relations = []
  data.each_with_index do |school, index|
    print "\rParsing spaces, space contacts and space type relations from nsr school data: #{index} / #{data.length}"

    space = new_unless_exists Space, space_from(school)
    spaces << space if space

    guaranteed_space_for_relations = space || (space_from(school) && Space.find_by(space_from(school)))

    space_type_relation = new_unless_exists(SpaceTypesRelation, {
      space: guaranteed_space_for_relations,
      space_type: SpaceType.find_by(space_type_from(school))
    })
    space_type_relations << space_type_relation if space_type_relation

    space_contact_space = guaranteed_space_for_relations
    next unless space_contact_space

    space_contacts_from(school).each do |contact|
      space_contact = new_unless_exists SpaceContact, contact
      if space_contact
        space_contact.space = space_contact_space
        space_contacts << space_contact if space_contact
      end
    end
  end

  # Save them all with import
  print "\nimporting #{spaces.length} spaces"
  Space.import(spaces)

  print "\nimporting #{space_type_relations.length} space type relations:"
  SpaceTypesRelation.import(space_type_relations)


  print "\nAggregating facility reviews for all #{Space.count} spaces:\n"

  Space.all.each_with_index do |space, index|
      print "\raggregating facility reviews for ##{index} / #{Space.count} / space_id: #{space.id}"
      space.aggregate_facility_reviews
  end

  print "\nimporting #{space_contacts.length} space contacts"
  SpaceContact.import(space_contacts)


  count_stats(info: "After import from NSR JSON:")
end

# rubocop:enable all
