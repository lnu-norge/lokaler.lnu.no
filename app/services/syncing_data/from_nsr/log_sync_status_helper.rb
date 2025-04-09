# frozen_string_literal: true

module SyncingData
  module FromNsr
    module LogSyncStatusHelper
      private

      def sync_id_for(school_data)
        school_data["Organisasjonsnummer"]
      end

      def start_sync_log(school_data)
        SyncStatus.for(id_from_source: sync_id_for(school_data), source: "nsr").log_start
      end

      def log_successful_sync(school_data)
        SyncStatus.for(id_from_source: sync_id_for(school_data), source: "nsr").log_success
      end

      def log_failed_sync(school_data, error)
        SyncStatus.for(id_from_source: sync_id_for(school_data), source: "nsr").log_failure(error)
      end
    end
  end
end
