# frozen_string_literal: true

Fabricator(:space) do
  title { Faker::Lorem.words number: 2 }
  address { Faker::Address.full_address }
  lat { Faker::Address.latitude }
  lng { Faker::Address.longitude }
  space_owner
  space_type
  star_rating { nil }
end
