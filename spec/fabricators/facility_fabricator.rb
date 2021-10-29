# frozen_string_literal: true

Fabricator(:facility) do
  title { Faker::Name.first_name }
  icon { Faker::Name.first_name }
  facility_category
end
