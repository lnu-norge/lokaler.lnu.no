# frozen_string_literal: true

module WithParentChildRelationship
  extend ActiveSupport::Concern

  private

  def no_circular_references
    return unless parent_id == id

    errors.add(:base, "Cannot add itself as a parent")
  end
end
