# frozen_string_literal: true

module SanitizeableIdList
  extend ActiveSupport::Concern

  private

  def sanitize_id_list(array_of_ids)
    return [] if array_of_ids.blank?

    array_of_ids.uniq.select { |id| id.to_i.to_s == id }.map(&:to_i)
  end
end
