# frozen_string_literal: true

Fabricator(:review) do
  title { Faker::Lorem.words(number: 2).join }
  comment { Faker::Lorem.sentences }
  price { Faker::Number.number(digits: 3) }
  star_rating { Faker::Number.between(from: 1, to: 5) }
  user
  space
end
