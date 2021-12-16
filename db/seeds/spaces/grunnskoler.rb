# frozen_string_literal: true

## Space Type
barneskole = SpaceType.create(
  type_name: "1. til 7."
)

## Space group
fredrikstad = SpaceGroup.create_or_find_by!(
  title: "Grunnskoler i Fredrikstad"
)

## Rich text fields
how_to_book = '<p>Nabbetorp skole er en
spesialskole og er ikke åpen for leie eller
lån. De ønsker ikke bli kontaktet.</p>'

## Create space
Space.create(
  title: "Nabbetorp spesialskole",
  address: "Enggata 76",
  post_number: "1636",
  post_address: "Gamle Fredrikstad",
  lat: 59.213868,
  lng: 10.972267,
  space_group_id: fredrikstad.id,
  space_type_id: barneskole.id,
  organization_number: "974766337",
  municipality_code: "3004",
  star_rating: nil,
  how_to_book: how_to_book
  # open_for_being_contacted: false
  # TODO: Add this to the model!
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
  space_group_id: fredrikstad.id,
  space_type_id: barne_og_ungdom.id,
  organization_number: "974766337",
  municipality_code: "3004",
  star_rating: nil
)
