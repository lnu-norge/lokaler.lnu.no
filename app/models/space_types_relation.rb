# frozen_string_literal: true

class SpaceTypesRelation < ApplicationRecord
  belongs_to :space_type
  belongs_to :space

  after_save do
    space.reload.aggregate_facility_reviews
  end

  after_destroy do
    space.reload.aggregate_facility_reviews
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
