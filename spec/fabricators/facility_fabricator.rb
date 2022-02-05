# frozen_string_literal: true

Fabricator(:facility) do
  title { Faker::Name.first_name }
  icon { Faker::Name.first_name }
end

# == Schema Information
#
# Table name: facilities
#
#  id         :bigint           not null, primary key
#  icon       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
