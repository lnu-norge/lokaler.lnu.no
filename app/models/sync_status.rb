# frozen_string_literal: true

class SyncStatus < ApplicationRecord
  belongs_to :space

  validates :source, presence: true
  validates :space_id, uniqueness: { scope: :source }

  def self.for(space:, source:)
    find_or_initialize_by(space: space, source: source)
  end

  def log_start
    update(last_attempted_sync_at: Time.current)
  end

  def log_success
    update(last_successful_sync_at: Time.current, last_attempt_was_successful: true)
  end

  def log_failure
    update(last_attempt_was_successful: false)
  end
end

# == Schema Information
#
# Table name: sync_statuses
#
#  id                          :bigint           not null, primary key
#  last_attempt_was_successful :boolean
#  last_attempted_sync_at      :datetime
#  last_successful_sync_at     :datetime
#  source                      :string           not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  space_id                    :bigint           not null
#
# Indexes
#
#  index_sync_statuses_on_space_id             (space_id)
#  index_sync_statuses_on_space_id_and_source  (space_id,source) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#
#
