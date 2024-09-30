# frozen_string_literal: true

class GeographicalAreaType < ApplicationRecord
  include WithParentChildRelationship

  validates :name, presence: true
end

# == Schema Information
#
# Table name: geographical_area_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint
#
# Indexes
#
#  index_geographical_area_types_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => geographical_area_types.id)
#
