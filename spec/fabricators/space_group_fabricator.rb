# frozen_string_literal: true

Fabricator(:space_group) do
  title Faker::Name.first_name
  about Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  how_to_book Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
  terms_and_pricing Faker::Lorem.paragraphs.map { |p| "<p>#{p}</p>" }.join
end

# == Schema Information
#
# Table name: space_groups
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
