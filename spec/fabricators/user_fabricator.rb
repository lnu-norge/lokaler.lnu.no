# frozen_string_literal: true

Fabricator(:user) do
  first_name { Faker::Superhero.prefix + Faker::Superhero.descriptor }
  last_name { Faker::Superhero.suffix }
  email { Faker::Internet.email }
  password 'password'
  password_confirmation 'password'
end
