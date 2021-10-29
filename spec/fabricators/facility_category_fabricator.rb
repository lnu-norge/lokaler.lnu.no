# frozen_string_literal: true

Fabricator(:facility_category) do
  title { Faker::Name.first_name }
end
