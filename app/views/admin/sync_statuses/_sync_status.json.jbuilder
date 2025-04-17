# frozen_string_literal: true

json.extract! sync_status, :id, :source, :last_attempted_sync_at, :last_successful_sync_at, :id_from_source,
              :error_message, :full_error_message, :created_at, :updated_at
json.url sync_status_url(sync_status, format: :json)
