# frozen_string_literal: true

class User < ApplicationRecord
  require "securerandom"
  devise :magic_link_authenticatable,
         :registerable,
         :rememberable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  include Gravtastic
  gravtastic default: "retro"

  has_many :reviews, dependent: :restrict_with_exception
  has_many :facility_reviews, dependent: :restrict_with_exception

  has_many :personal_space_lists, dependent: :destroy
  has_many :personal_space_lists_shared_with_mes, dependent: :destroy
  has_one :active_personal_space_list, dependent: :destroy

  has_many :login_attempts, dependent: :destroy
  has_many :user_presence_logs, dependent: :destroy

  validates :organization_name, presence: true, if: -> { in_organization == true }

  # Scopes for STI
  scope :humans, -> { where(type: nil) }
  scope :robots, -> { where(type: "Robot") }

  # Type checking methods
  def human?
    !robot?
  end

  def robot?
    is_a?(Robot)
  end

  def name
    return nil if first_name.blank? && last_name.blank?
    return first_name if last_name.blank?
    return last_name if first_name.blank?

    "#{first_name} #{last_name[0]&.upcase}."
  end

  def full_name
    return nil if first_name.blank? && last_name.blank?
    return first_name if last_name.blank?
    return last_name if first_name.blank?

    "#{first_name} #{last_name}"
  end

  def organization
    return organization_name if in_organization == true
    return "Privatperson" if in_organization == false

    nil
  end

  def facility_review_for(facility_id, space)
    FacilityReview.find_or_initialize_by(
      space:,
      facility_id:,
      user: self
    )
  end

  def self.from_google(email:, first_name:, last_name:)
    create_with(first_name:,
                last_name:)
      .find_or_create_by!(email:)
  end

  def missing_information?
    first_name.blank? || organization.blank?
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
#  in_organization        :boolean
#  last_name              :string
#  organization_name      :string
#  remember_created_at    :datetime
#  remember_token         :string(20)
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  type                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_type                  (type)
#
