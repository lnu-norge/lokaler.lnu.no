# frozen_string_literal: true

class LoginAttempt < ApplicationRecord
  belongs_to :user, optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :login_method, presence: true
  validates :status, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_email, ->(email) { where(email: email) }
  scope :since, ->(date) { where(created_at: date..) }

  enum :login_method, {
    magic_link: "magic_link",
    google_oauth: "google_oauth"
  }

  enum :status, {
    pending: "pending",
    successful: "successful",
    failed: "failed"
  }
end

# == Schema Information
#
# Table name: login_attempts
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  failed_reason :string
#  login_method  :string           not null
#  status        :string           default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint
#
# Indexes
#
#  index_login_attempts_on_email    (email)
#  index_login_attempts_on_status   (status)
#  index_login_attempts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
