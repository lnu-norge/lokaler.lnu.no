# frozen_string_literal: true

Fabricator(:review) do
  title { Faker::Lorem.sentence(word_count: 4) }
  comment { Faker::Lorem.sentences }
  price { Faker::Number.number(digits: 3) }
  star_rating { Faker::Number.between(from: 1, to: 5) }
  organization
  type_of_contact { :been_there }
  user
  space
end
