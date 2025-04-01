# frozen_string_literal: true

module Admin
  module HistoryHelper
    include Pagy::Frontend

    def dom_id_history_of(version)
      "history_for_#{version.item_type}_#{version.item_id}"
    end
  end
end
