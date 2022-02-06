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

  def new_facility_review_for(facility_id, space)
    FacilityReview.new(
      space: space,
      facility_id: facility_id,
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

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  organization           :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
