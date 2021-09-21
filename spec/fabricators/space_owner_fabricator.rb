# frozen_string_literal: true

Fabricator(:space_owner) do
  orgnr { Faker::Number.number(digits: 9) }
end
