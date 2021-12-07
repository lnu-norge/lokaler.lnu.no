# frozen_string_literal: true

## Space Owner
require "./db/seeds/space_owners/viken"
viken = create_viken

## Space Type
vgs = SpaceType.create(
  type_name: "VGS"
)

## Rich text fields
how_to_book = "<p>All booking foregår gjennom resepsjonen.
Ta først kontakt med dem og spør om vi kan leie,
 og så vil du bli bedt om å fylle ut
<a href='#'>skjema for Viken fylke</a>.</p>"
who_can_use = nil
pricing = nil
terms = '<p>Må rydde så klasserom, pulter, og
annet er likt som når man kom.</p>
<p>Ta før-og-etter-bilder for å sikre at alt
 er som det var når dere tok over. </p>'
more_info = '<p>Frederik II er delt i to bygg.
Avdeling Frydenberg ligger i øst, og Christianlund
i vest. Man kan leie begge samtidig, eller seperat.</p>'

## Full Space, without images
frederikii_space = Space.create(
  title: "Frederik II",
  address: "Merkurveien 12",
  post_number: "1613",
  post_address: "Fredrikstad",
  lat: 59.223840,
  lng: 10.925860,
  space_owner_id: viken.id,
  space_type_id: vgs.id,
  organization_number: "974544466",
  municipality_code: "3004",
  star_rating: nil,
  how_to_book: how_to_book,
  who_can_use: who_can_use,
  pricing: pricing,
  terms: terms,
  more_info: more_info
)

require_relative "../reviews/reviews"
demo_reviews_for_space(frederikii_space)

## Attach some sample images
images = %w[
  ./db/seeds/images/outside_school.jpg
  ./db/seeds/images/auditorium.jpg
  ./db/seeds/images/classroom.jpg
].map do |path|
  filename = File.basename(path)
  file = File.open(path)
  {
    io: file, filename: filename, content_type: "image/jpg"
  }
end

## NB! We don't know why, but seeding images does not work unless it's the last thing
# that's done in the file. Presumably, we have to wait for the image to upload or
# attach properly, but neither sleep 5, nor any other attempts at saving the space
# has worked. To reproduce, simply reload with frederikii_space.reload after the images
# are attached, and they will not be uploaded. Please fix if you know how!
# Might be related to https://github.com/rails/rails/issues/37304#issuecomment-546246357
frederikii_space.images.attach images
