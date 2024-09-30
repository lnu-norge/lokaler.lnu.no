# frozen_string_literal: true

class GeographicalArea < ApplicationRecord
  include WithParentChildRelationship

  belongs_to :parent, class_name: "GeographicalArea", optional: true, inverse_of: :children
  has_many :children, class_name: "GeographicalArea", foreign_key: "parent_id", dependent: :nullify, inverse_of: :parent
  validate :no_circular_references

  has_many :spaces, dependent: :nullify

  belongs_to :geographical_area_type

  validates :name, presence: true
  validates :geo_area, presence: true
end

# == Schema Information
#
# Table name: geographical_areas
#
#  id                            :bigint           not null, primary key
#  external_source               :string
#  filterable                    :boolean          default(TRUE)
#  geo_area                      :geometry         not null, geometry, 0
#  name                          :string
#  order                         :integer
#  unique_id_for_external_source :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  geographical_area_type_id     :bigint
#  parent_id                     :bigint
#
# Indexes
#
#  index_geographical_areas_on_geo_area                   (geo_area) USING gist
#  index_geographical_areas_on_geographical_area_type_id  (geographical_area_type_id)
#  index_geographical_areas_on_parent_id                  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (geographical_area_type_id => geographical_area_types.id)
#  fk_rails_...  (parent_id => geographical_areas.id)
#
