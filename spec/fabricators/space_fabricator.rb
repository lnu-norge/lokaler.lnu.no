# frozen_string_literal: true

Fabricator(:space) do
  title { Faker::Name.first_name }
  address { Faker::Address.street_address }
  post_number { Faker::Number.number(digits: 4) }
  post_address { Faker::Address.city }
  lat { Faker::Address.latitude }
  lng { Faker::Address.longitude }
  space_group
  space_type
  star_rating { nil }
end
