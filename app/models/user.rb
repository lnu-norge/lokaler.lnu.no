# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include Gravtastic
  gravtastic default: "retro"

  has_many :reviews, dependent: :restrict_with_exception
  has_many :facility_reviews, dependent: :restrict_with_exception

  def name
    return first_name unless last_name&.present?
    return last_name unless first_name&.present?

    "#{first_name} #{last_name[0]&.upcase}."
  end

  def facility_review_for(facility_id, space)
    facility_reviews.find_by(facility: facility_id) || FacilityReview.new(
      space: space,
      facility_id: facility_id,
      user: self
    )
  end
end
