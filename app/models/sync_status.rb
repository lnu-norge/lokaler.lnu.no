# frozen_string_literal: true

class SyncStatus < ApplicationRecord
  belongs_to :space, optional: true

  validates :source, presence: true
  validates :id_from_source, presence: true, uniqueness: { scope: :source }

  def self.for(source:, id_from_source:)
    find_or_create_by!(id_from_source:, source:)
  end

  def self.for_space(space, source:)
    find_or_initialize_by(space: space, source: source) do |sync_status|
      sync_status.update(id_from_source: space.id)
      sync_status.save!
    end
  end

  def log_start
    update(last_attempted_sync_at: Time.current)
  end

  def log_success
    update(last_successful_sync_at: Time.current, last_attempt_was_successful: true)
    update(error_message: nil)
  end

  def log_failure(error)
    error_message = error.respond_to?(:message) ? error.message : error.to_s
    full_error_message = error.respond_to?(:full_message) ? error.full_message : ""

    Rails.logger.error("Error when syncing #{source}: #{error_message}")
    update(last_attempt_was_successful: false) if valid?
    update(error_message:)
    update(full_error_message:)
  end
end

# == Schema Information
#
# Table name: sync_statuses
#
#  id                          :bigint           not null, primary key
#  error_message               :string
#  full_error_message          :text
#  id_from_source              :string           not null
#  last_attempt_was_successful :boolean
#  last_attempted_sync_at      :datetime
#  last_successful_sync_at     :datetime
#  source                      :string           not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  space_id                    :bigint
#
# Indexes
#
#  index_sync_statuses_on_id_from_source_and_source  (id_from_source,source) UNIQUE
#  index_sync_statuses_on_source                     (source)
#  index_sync_statuses_on_space_id                   (space_id)
#  index_sync_statuses_on_space_id_and_source        (space_id,source) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#
