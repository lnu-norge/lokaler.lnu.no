# frozen_string_literal: true

## Space Group
viken = SpaceGroup.create_or_find_by(
  title: "Fredrikstad kommune"
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
  space_group_id: viken.id,
  space_type_id: barne_og_ungdom.id,
  organization_number: "974766337",
  municipality_code: "3004",
  star_rating: nil
)
