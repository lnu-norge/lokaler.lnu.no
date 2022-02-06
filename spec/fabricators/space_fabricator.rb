# frozen_string_literal: true

Fabricator(:space) do
  title { Faker::Name.first_name }
  address { Faker::Address.street_address }
  post_number { Faker::Number.number(digits: 4) }
  post_address { Faker::Address.city }
  lat { Faker::Address.latitude }
  lng { Faker::Address.longitude }
  space_group
  space_types { [Fabricate(:space_type)] }
  star_rating { nil }
end

# == Schema Information
#
# Table name: spaces
#
#  id                  :bigint           not null, primary key
#  address             :string
#  lat                 :decimal(, )
#  lng                 :decimal(, )
#  municipality_code   :string
#  organization_number :string
#  post_address        :string
#  post_number         :string
#  star_rating         :decimal(2, 1)
#  title               :string           not null
#  url                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  space_group_id      :bigint
#
# Indexes
#
#  index_spaces_on_space_group_id  (space_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (space_group_id => space_groups.id)
#
