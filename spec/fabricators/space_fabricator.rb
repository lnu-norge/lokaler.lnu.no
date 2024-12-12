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

  after_create do |space|
    add_some_space_facilities(space)
  end
end

def add_some_space_facilities(space)
  space_type = space.space_types.first

  relevant_facility_one = Fabricate(:facility)
  relevant_facility_two = Fabricate(:facility)

  # Make them relevant by connecting them to our space_type
  # This also runs aggregate facility reviews, so creates
  # space_facilities for them (with unknown experience)
  Fabricate(:space_types_facility,
            space_type:,
            facility: relevant_facility_one)
  Fabricate(:space_types_facility,
            space_type:,
            facility: relevant_facility_two)

  # Then create four irrelevant facilities and connect them to our space
  Fabricate.times(4,
                  :space_facility,
                  space:)

  # Then aggregate reviews
  space.aggregate_facility_reviews
end

# == Schema Information
#
# Table name: spaces
#
#  id                   :bigint           not null, primary key
#  address              :string
#  geo_point            :geography        not null, point, 4326
#  lat                  :decimal(, )
#  lng                  :decimal(, )
#  location_description :text
#  municipality_code    :string
#  organization_number  :string
#  post_address         :string
#  post_number          :string
#  star_rating          :decimal(2, 1)
#  title                :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  fylke_id             :bigint
#  kommune_id           :bigint
#  space_group_id       :bigint
#
# Indexes
#
#  index_spaces_on_fylke_id        (fylke_id)
#  index_spaces_on_geo_point       (geo_point) USING gist
#  index_spaces_on_kommune_id      (kommune_id)
#  index_spaces_on_space_group_id  (space_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (fylke_id => geographical_areas.id)
#  fk_rails_...  (kommune_id => geographical_areas.id)
#  fk_rails_...  (space_group_id => space_groups.id)
#
