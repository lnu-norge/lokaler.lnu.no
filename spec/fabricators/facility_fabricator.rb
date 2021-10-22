# frozen_string_literal: true

Fabricator(:facility) do
  title { Faker::Lorem.sentences(number: 1) }
  icon { Faker::Name.first_name }
  facility_category
end
