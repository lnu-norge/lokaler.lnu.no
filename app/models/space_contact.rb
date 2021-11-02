# frozen_string_literal: true

class SpaceContact < ApplicationRecord
  belongs_to :space, optional: true
  belongs_to :space_owner

  after_create_commit { broadcast_prepend_to 'space_contacts' }
  after_update_commit { broadcast_replace_to 'space_contacts' }
  after_destroy_commit { broadcast_remove_to 'space_contacts' }

  validates :title, presence: true
end
