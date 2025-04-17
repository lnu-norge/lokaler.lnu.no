# frozen_string_literal: true

Fabricator(:sync_status, class_name: "Admin::SyncStatus") do
  source { %w[brreg nsr].sample }
  id_from_source { sequence(:id_from_source) { |i| "ID#{i}" } }
  last_attempted_sync_at { Time.current }
  last_successful_sync_at { [Time.current, nil].sample }
  error_message { [nil, "Some error occurred"].sample }
  full_error_message { |attrs| attrs[:error_message] ? "Full details: #{attrs[:error_message]}" : nil }
end
