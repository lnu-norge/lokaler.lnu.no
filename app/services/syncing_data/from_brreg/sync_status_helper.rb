# frozen_string_literal: true

module SyncingData
  module FromBrreg
    module SyncStatusHelper
      private

      def start_sync_log(id_from_source)
        Admin::SyncStatus.for(id_from_source:, source: "brreg").log_start
      end

      def log_successful_sync(id_from_source)
        Admin::SyncStatus.for(id_from_source:, source: "brreg").log_success
      end

      def log_failed_sync(id_from_source, error)
        Admin::SyncStatus.for(id_from_source:, source: "brreg").log_failure(error)
      end
    end
  end
end
