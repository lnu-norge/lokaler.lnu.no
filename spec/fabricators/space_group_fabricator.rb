# frozen_string_literal: true

Fabricator(:space_group) do
  title Faker::Name.first_name
  about Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  how_to_book Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  terms Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  pricing Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  who_can_use Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
end
