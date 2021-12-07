# frozen_string_literal: true

class SpaceContact < ApplicationRecord
  has_paper_trail

  belongs_to :space, optional: true
  belongs_to :space_group, optional: true

  after_create_commit { broadcast_prepend_to "space_contacts", partial: "space_contacts/space_contact" }
  after_update_commit { broadcast_replace_to "space_contacts", partial: "space_contacts/space_contact" }
  after_destroy_commit { broadcast_remove_to "space_contacts" }

  include ParseUrlHelper
  before_validation :parse_url

  validates :title, presence: true
  validates :telephone, phone: { allow_blank: true }
  validates :url, url: { allow_blank: true, public_suffix: true }
  validate :any_present?
  validates :space, presence: true, unless: :space_group
  validates :space_group, presence: true, unless: :space

  def any_present?
    fields = %w[telephone url email description]

    return unless fields.all? { |attr| self[attr].blank? }

    fields.each do |field|
      errors.add field, I18n.t("space_contact.at_least_one_error_message.#{field}")
    end
  end
end
