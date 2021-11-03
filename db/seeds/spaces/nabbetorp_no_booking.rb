# frozen_string_literal: true

## Space Owner
viken = SpaceOwner.create(
  orgnr: "921693230"
)

## Space Type
barneskole = SpaceType.create(
  type_name: "1. til 7."
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
  space_owner_id: viken.id,
  space_type_id: barneskole.id,
  organization_number: "974766337",
  municipality_code: "3004",
  fits_people: nil,
  star_rating: nil,
  how_to_book: how_to_book
  # open_for_being_contacted: false
  # TODO: Add this to the model!
)
