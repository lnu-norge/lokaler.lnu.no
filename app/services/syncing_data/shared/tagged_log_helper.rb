# frozen_string_literal: true

module SyncingData
  module Shared
    module TaggedLogHelper
      private

      def logger
        rails_logger_with_tags
      end

      # Overwrite this method to use a different tag
      def rails_logger_with_tags
        Rails.logger.tagged("SyncingData")
      end
    end
  end
end
