# frozen_string_literal: true

class User < ApplicationRecord
  require "securerandom"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  include Gravtastic
  gravtastic default: "retro"

  has_many :reviews, dependent: :restrict_with_exception
  has_many :facility_reviews, dependent: :restrict_with_exception

  def name
    return first_name unless last_name&.present?
    return last_name unless first_name&.present?

    "#{first_name} #{last_name[0]&.upcase}."
  end

  def facility_review_for(facility, space)
    facility_reviews.find_by(facility: facility.id) || FacilityReview.new(
      space: space,
      facility: facility,
      user: self
    )
  end

  def self.from_google(email:, first_name:, last_name:)
    create_with(first_name: first_name,
                last_name: last_name,
                password: SecureRandom.base64(13))
      .find_or_create_by!(email: email)
  end
end
