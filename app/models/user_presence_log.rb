# frozen_string_literal: true

class UserPresenceLog < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :user_id, uniqueness: { scope: :date }

  scope :recent, -> { order(date: :desc) }
  scope :for_date, ->(date) { where(date: date) }
  scope :since, ->(date) { where(date: date..) }
  scope :between, ->(start_date, end_date) { where(date: start_date..end_date) }

  def self.log_user_presence(user, date = Date.current)
    find_or_create_by(user: user, date: date)
  end
end

# == Schema Information
#
# Table name: user_presence_logs
#
#  id         :bigint           not null, primary key
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_presence_logs_on_date              (date)
#  index_user_presence_logs_on_user_id           (user_id)
#  index_user_presence_logs_on_user_id_and_date  (user_id,date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
