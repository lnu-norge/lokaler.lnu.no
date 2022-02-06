# frozen_string_literal: true

class FacilityCategory < ApplicationRecord
  has_many :facilities_categories, dependent: :destroy
  has_many :facilities, through: :facilities_categories

  belongs_to :parent, class_name: FacilityCategory.name, optional: true
  has_many :children, class_name: FacilityCategory.name, foreign_key: :parent_id, inverse_of: :parent,
                      dependent: :destroy
end

# == Schema Information
#
# Table name: facility_categories
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint
#
# Indexes
#
#  index_facility_categories_on_parent_id  (parent_id)
#
