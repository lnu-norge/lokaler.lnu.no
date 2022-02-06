# frozen_string_literal: true

Fabricator(:space_type) do
  type_name { Faker::Dessert.variety }
end

# == Schema Information
#
# Table name: space_types
#
#  id         :bigint           not null, primary key
#  type_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
