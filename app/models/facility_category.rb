# frozen_string_literal: true

class FacilityCategory < ApplicationRecord
  has_many :facilities_categories, dependent: :destroy
  has_many :facilities, through: :facilities_categories

  belongs_to :parent, class_name: FacilityCategory.name, optional: true
  has_many :children, class_name: FacilityCategory.name, foreign_key: :parent_id, inverse_of: :parent,
                      dependent: :destroy
end
