# frozen_string_literal: true

class SpaceTypesFacility < ApplicationRecord
  belongs_to :space_type
  belongs_to :facility
end

# == Schema Information
#
# Table name: space_types_facilities
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  facility_id   :bigint           not null
#  space_type_id :bigint           not null
#
# Indexes
#
#  index_space_types_facilities_on_facility_id    (facility_id)
#  index_space_types_facilities_on_space_type_id  (space_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (space_type_id => space_types.id)
#
