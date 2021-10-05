# frozen_string_literal: true

Fabricator(:facility_category) do
  title { Faker::Lorem.sentences(number: 1) }
end
