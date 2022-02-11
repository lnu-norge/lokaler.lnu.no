# frozen_string_literal: true

## Space Type
bibliotek = SpaceType.create(
  type_name: "Bibliotek",
  facilities: [
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
)

## Space group
fredrikstad = SpaceGroup.create_or_find_by!(
  title: "Grunnskoler i Fredrikstad"
)

## Rich text fields
how_to_book = "<p>Nabbetorp bibliotek er et helt vanlig bibliotek.</p>"

## Create space
Space.create(
  title: "Nabbetorp Bibliotek",
  address: "Enggata 76",
  post_number: "1636",
  post_address: "Gamle Fredrikstad",
  lat: 59.213868,
  lng: 10.972267,
  space_group_id: fredrikstad.id,
  space_types: [bibliotek],
  organization_number: "974766337",
  municipality_code: "3004",
  star_rating: nil,
  how_to_book: how_to_book
  # open_for_being_contacted: false
  # TODO: Add this to the model!
)

## Space Type
barne_og_ungdom = SpaceType.create(
  type_name: "1. til 10.",
  facilities: [
    Facility.find_by(title: "Gymsal"),
    Facility.find_by(title: "Klasserom"),
    Facility.find_by(title: "Sove på gulvet"),
    Facility.find_by(title: "Kjøkken med ovn"),
    Facility.find_by(title: "Rullestolvennlig inngang"),
    Facility.find_by(title: "Rullestolvennlig inne"),
    Facility.find_by(title: "HC-toalett")
  ]
)

## Empty Space, only info from NSR
Space.create(
  title: "Gudeberg skole",
  address: "Nabbetorpveien 15",
  post_number: "1632",
  post_address: "Gamle Fredrikstad",
  lat: 59.205250,
  lng: 10.962680,
  space_group_id: fredrikstad.id,
  space_types: [barne_og_ungdom],
  organization_number: "974766337",
  municipality_code: "3004",
  star_rating: nil
)
