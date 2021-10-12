# frozen_string_literal: true

Fabricator(:space_owner) do
  title Faker::Nation.capital_city
  orgnr Faker::Number.number(digits: 9)
  how_to_book Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  terms Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  pricing Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  who_can_use Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
end
