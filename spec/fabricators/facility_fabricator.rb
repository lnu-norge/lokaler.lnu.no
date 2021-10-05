# frozen_string_literal: true

Fabricator(:facility) do
  title { Faker::Lorem.sentences(number: 1) }
end
