# frozen_string_literal: true

Fabricator(:space_type) do
  type_name { Faker::Dessert.variety }
end
