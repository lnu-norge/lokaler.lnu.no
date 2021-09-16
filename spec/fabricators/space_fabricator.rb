# frozen_string_literal: true

Fabricator(:space) do
  address { Faker::Address.full_address }
  lat { Faker::Address.latitude }
  long { Faker::Address.longitude }
  organization
  space_type
end
