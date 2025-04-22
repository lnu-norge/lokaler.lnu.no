# frozen_string_literal: true

module SyncingData
  module FromBrreg
    module TaggedLogHelper
      include SyncingData::Shared::TaggedLogHelper

      private

      def rails_logger_with_tags
        Rails.logger.tagged("SyncingData").tagged("FromBRREG")
      end
    end
  end
end
