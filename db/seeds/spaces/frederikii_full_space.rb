# frozen_string_literal: true

## Space Group
require "./db/seeds/space_groups/viken"
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
  space_group_id: viken.id,
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

short_caption = "Skolen er stygg"
long_caption = "Som du kan se her, så finner du ikke akkurat ut hva denne teksten skal handle om
- du må bare lese og lese, så til slutt så kanskje du finner ut hva det handler om."
credit_for_short = "Daniel Jackson"
credit_for_long = "Kari Nordmann, Philip Nordmann, Vilma Nordmann, Eva Nordmann, Marcus Nordmann,
og mange flere samarbeidet om å ta dette bildet"
credit_only = "Ola Nordmann"

def attach_image(space, path, caption, credit)
  filename = File.basename(path)
  file = File.open(path)
  img = Image.create!(
    space_id: space.id,
    caption: caption,
    credits: credit
  )
  img.image.attach io: file, filename: filename, content_type: "image/jpg"
end

## Attach some sample images
attach_image frederikii_space, "./db/seeds/images/outside_school.jpg", short_caption, credit_for_short
attach_image frederikii_space, "./db/seeds/images/auditorium.jpg", long_caption, credit_for_long
attach_image frederikii_space, "./db/seeds/images/classroom.jpg", nil, credit_only
attach_image frederikii_space, "./db/seeds/images/classroom_2.jpg", nil, nil
