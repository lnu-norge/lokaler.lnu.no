# frozen_string_literal: true

class SpaceType < ApplicationRecord
  has_paper_trail

  has_many :space_types_relation, dependent: :destroy
  has_many :spaces, through: :space_types_relation, dependent: :destroy

  has_many :space_types_facilities, dependent: :destroy
  has_many :facilities, through: :space_types_facilities, dependent: :destroy
end

# == Schema Information
#
# Table name: space_types
#
#  id         :bigint           not null, primary key
#  type_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
