# frozen_string_literal: true

json.array! @sync_statuses, partial: "sync_statuses/sync_status", as: :sync_status
