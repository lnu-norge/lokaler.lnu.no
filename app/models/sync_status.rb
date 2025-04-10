# frozen_string_literal: true

class SyncStatus < ApplicationRecord
  validates :source, presence: true
  validates :id_from_source, presence: true, uniqueness: { scope: :source }

  scope :successful, -> { where.not(last_successful_sync_at: nil) }
  scope :failed, -> { where(last_successful_sync_at: nil) }

  def self.for(source:, id_from_source:)
    find_or_create_by!(id_from_source:, source:)
  end

  def log_start
    update(last_attempted_sync_at: Time.current)
  end

  def log_success
    update(last_successful_sync_at: Time.current)
    clear_error_messages
  end

  def log_failure(error)
    update_error_messages_with(error)

    Rails.logger.error("Error when syncing #{source}: #{error_message}")
    update(last_successful_sync_at: nil)
  end

  private

  def clear_error_messages
    update(
      error_message: nil,
      full_error_message: nil
    )
  end

  def update_error_messages_with(error)
    error_message = error.respond_to?(:message) ? error.message : error.to_s
    full_error_message = error.respond_to?(:full_message) ? error.full_message : ""
    update(
      error_message:,
      full_error_message:
    )
  end
end

# == Schema Information
#
# Table name: sync_statuses
#
#  id                      :bigint           not null, primary key
#  error_message           :string
#  full_error_message      :text
#  id_from_source          :string           not null
#  last_attempted_sync_at  :datetime
#  last_successful_sync_at :datetime
#  source                  :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_sync_statuses_on_id_from_source_and_source  (id_from_source,source) UNIQUE
#  index_sync_statuses_on_source                     (source)
#
