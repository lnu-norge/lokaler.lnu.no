# frozen_string_literal: true

module SyncingData
  module FromNsr
    module SyncStatusHelper
      private

      def sync_id_for(school_data)
        school_data["Organisasjonsnummer"]
      end

      def start_sync_log(school_data)
        Admin::SyncStatus.for(id_from_source: sync_id_for(school_data), source: "nsr").log_start
      end

      def log_successful_sync(school_data)
        Admin::SyncStatus.for(id_from_source: sync_id_for(school_data), source: "nsr").log_success
      end

      def log_failed_sync(school_data, error)
        Admin::SyncStatus.for(id_from_source: sync_id_for(school_data), source: "nsr").log_failure(error)
      end
    end
  end
end
