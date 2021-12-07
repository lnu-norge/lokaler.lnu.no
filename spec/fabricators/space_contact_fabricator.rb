# frozen_string_literal: true

Fabricator(:space_contact) do
  title { Faker::Name.name }
  telephone { "40482128" }
  telephone_opening_hours { "Open from: #{opening_hours(10, 5)} to #{opening_hours(4, 0)}" }
  email { Faker::Internet.email }
  url { Faker::Internet.url }
  description { Faker::Lorem.sentence(word_count: 2, random_words_to_add: 3) }
  priority { Faker::Number.between(from: 1, to: 5) }
  space
  space_group
end

def opening_hours(start, stop)
  Faker::Time.between(from: DateTime.now - start, to: DateTime.now - stop)
end
