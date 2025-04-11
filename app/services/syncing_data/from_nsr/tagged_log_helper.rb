# frozen_string_literal: true

module SyncingData
  module FromNsr
    module TaggedLogHelper
      include SyncingData::Shared::TaggedLogHelper

      private

      def rails_logger_with_tags
        Rails.logger.tagged("SyncingData").tagged("FromNSR")
      end
    end
  end
end
