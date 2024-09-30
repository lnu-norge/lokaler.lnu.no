# frozen_string_literal: true

module WithParentChildRelationship
  extend ActiveSupport::Concern

  belongs_to :parent, class_name: name, optional: true, inverse_of: :children
  has_many :children, class_name: name, foreign_key: "parent_id", dependent: :nullify, inverse_of: :parent

  validate :no_circular_references

  private

  def no_circular_references
    return unless parent.present? && parent.children.include?(self)

    errors.add(:base, "Cannot add itself as a parent")
  end
end
