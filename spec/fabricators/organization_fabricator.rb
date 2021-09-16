# frozen_string_literal: true

Fabricator(:organization) do
  orgnr { Faker::Number.number(digits: 9) }
end
