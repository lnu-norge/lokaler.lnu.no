# frozen_string_literal: true

Fabricator(:space_facility) do
  facility
  relevant true
  experience :unknown
end

# == Schema Information
#
# Table name: space_facilities
#
#  id          :bigint           not null, primary key
#  description :string
#  experience  :integer
#  relevant    :boolean          default(FALSE)
#  score       :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  facility_id :bigint           not null
#  space_id    :bigint           not null
#
# Indexes
#
#  index_space_facilities_on_facility_id               (facility_id)
#  index_space_facilities_on_space_id                  (space_id)
#  index_space_facilities_on_space_id_and_facility_id  (space_id,facility_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (space_id => spaces.id)
#
