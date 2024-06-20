# frozen_string_literal: true

Fabricator(:personal_space_list) do
  title { Faker::Name }
  user
end
