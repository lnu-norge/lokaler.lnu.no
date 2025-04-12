# frozen_string_literal: true

## Space Type
bibliotek = SpaceType.find_by(type_name: "Bibliotek")

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
  how_to_book:
  # open_for_being_contacted: false
  # TODO: Add this to the model!
)

## Space Type
grunnskole = SpaceType.find_by(type_name: "Grunnskole")

## Empty Space, only info from NSR
Space.create(
  title: "Gudeberg skole",
  address: "Nabbetorpveien 15",
  post_number: "1632",
  post_address: "Gamle Fredrikstad",
  lat: 59.205250,
  lng: 10.962680,
  space_group_id: fredrikstad.id,
  space_types: [grunnskole],
  organization_number: "974766337",
  municipality_code: "3004",
  star_rating: nil
)
