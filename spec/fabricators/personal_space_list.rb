# frozen_string_literal: true

Fabricator(:personal_space_list) do
  title { Faker::String.random(length: 4..60) }
  user
end
