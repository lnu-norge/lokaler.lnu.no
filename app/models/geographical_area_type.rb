# frozen_string_literal: true

class GeographicalAreaType < ApplicationRecord
  include WithParentChildRelationship

  belongs_to :parent, class_name: "GeographicalArea", optional: true, inverse_of: :children
  has_many :children, class_name: "GeographicalArea", foreign_key: "parent_id", dependent: :nullify, inverse_of: :parent
  validate :no_circular_references

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
