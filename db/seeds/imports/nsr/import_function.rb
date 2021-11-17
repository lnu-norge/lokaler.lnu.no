# frozen_string_literal: true

# rubocop:disable all

require "json"
require "set"
require "./db/seeds/imports/nsr/helpers"

def import_spaces_from_nsr_schools
  # Counts
  p({
      info: "In db before import from NSR:",
      spaces: Space.count,
      space_types: SpaceType.count,
      space_owners: SpaceOwner.count,
      space_contacts: SpaceContact.count
    })

  # Load json file
  file = File.read(Rails.root.join("db", "seeds", "imports", "nsr", "nsrParsedSchools.json"))
  data = filter_schools(JSON.parse(file))

  p raw_schools_to_parse: data.length

  # Set up and save SpaceTypes
  space_types = [
    { type_name: "barneskole" },
    { type_name: "ungdomsskole" },
    { type_name: "grunnskole" },
    { type_name: "vgs" }
  ]
  SpaceType.import new_all_unless_exists(SpaceType, space_types)

  # Trawl through it, and extract information into Rails format

  # Set up owners first:
  space_owners = Set[]
  data.each do |school|
    space_owners << space_owner_from(school)
  end
  # Save them
  SpaceOwner.import new_all_unless_exists(SpaceOwner, space_owners)

  # Then start parsing Spaces, as they depend on the above
  spaces = []
  data.each do |school|
    space = new_unless_exists Space, space_from(school)
    next unless space

    space = add_space_contacts_from(school, space)
    spaces << space
  end
  # Save them all with import
  Space.import spaces, recursive: true

  p({
      info: "To import from NSR JSON:",
      spaces: spaces.length,
      space_types: space_types.length,
      space_owners: space_owners.length
    })
  p({
      info: "In db after import from NSR:",
      spaces: Space.count,
      space_types: SpaceType.count,
      space_owners: SpaceOwner.count,
      space_contacts: SpaceContact.count
    })
end

# rubocop:enable all
