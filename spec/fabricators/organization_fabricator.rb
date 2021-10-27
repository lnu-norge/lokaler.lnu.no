# frozen_string_literal: true

Fabricator(:organization) do
  name { Faker::Name.name }
end
