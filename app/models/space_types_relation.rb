# frozen_string_literal: true

class SpaceTypesRelation < ApplicationRecord
  belongs_to :space_type
  belongs_to :space

  after_commit do
    # Only run this if space is not being destroyed
    next if space.blank? || space.destroyed?

    space.aggregate_facility_reviews(facilities: space_type.facilities)
  end
end

# == Schema Information
#
# Table name: space_types_relations
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  space_id      :bigint           not null
#  space_type_id :bigint           not null
#
# Indexes
#
#  index_space_types_relations_on_space_id       (space_id)
#  index_space_types_relations_on_space_type_id  (space_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (space_type_id => space_types.id)
#
