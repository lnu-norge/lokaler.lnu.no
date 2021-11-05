# frozen_string_literal: true

class SpaceContact < ApplicationRecord
  has_paper_trail

  belongs_to :space, optional: true
  belongs_to :space_owner

  after_create_commit { broadcast_prepend_to 'space_contacts', partial: 'space_contacts/space_contact' }
  after_update_commit { broadcast_replace_to 'space_contacts', partial: 'space_contacts/space_contact' }
  after_destroy_commit { broadcast_remove_to 'space_contacts' }

  validates :title, presence: true
  validate :any_present?

  def any_present?
    if %w[telephone email url description].all? { |attr| self[attr].blank? } # rubocop:disable Style/GuardClause
      errors.add :base, I18n.t('space_contact.at_least_one_error_message')
    end
  end
end
