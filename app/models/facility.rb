# frozen_string_literal: true

class Facility < ApplicationRecord
  has_many :facilities_categories, dependent: :destroy
  has_many :facility_categories, through: :facilities_categories
end

# == Schema Information
#
# Table name: facilities
#
#  id         :bigint           not null, primary key
#  icon       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
