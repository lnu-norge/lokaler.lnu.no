# frozen_string_literal: true

## Space Owner
viken = SpaceOwner.create(
  orgnr: "921693230"
)

## Space Type
barne_og_ungdom = SpaceType.create(
  type_name: "1. til 10."
)

## Empty Space, only info from NSR
Space.create(
  title: "Gudeberg skole",
  address: "Nabbetorpveien 15",
  post_number: "1632",
  post_address: "Gamle Fredrikstad",
  lat: 59.205250,
  lng: 10.962680,
  space_owner_id: viken.id,
  space_type_id: barne_og_ungdom.id,
  organization_number: "974766337",
  municipality_code: "3004",
  fits_people: nil,
  star_rating: nil
)
