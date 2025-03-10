# frozen_string_literal: true

class PersonalDataOnSpaceInList < ApplicationRecord
  belongs_to :space
  belongs_to :personal_space_list
  belongs_to :personal_space_lists_space,
             foreign_key: [:space_id, :personal_space_list_id],
             optional: true,
             inverse_of: :personal_data_on_space_in_lists

  enum :contact_status, { not_contacted: 0, said_no: 1, said_maybe: 2, said_yes: 3 }

  after_create :update_personal_space_list_counters
  after_update :update_personal_space_list_counters
  after_destroy :update_personal_space_list_counters

  ICON_FOR_CONTACT_STATUS = {
    "not_contacted" => "unknown",
    "said_no" => "unlikely",
    "said_maybe" => "maybe",
    "said_yes" => "likely"
  }.freeze

  private

  def update_personal_space_list_counters
    personal_space_list.update_counter_caches if personal_space_list.present?
  end
end

# == Schema Information
#
# Table name: personal_data_on_space_in_lists
#
#  contact_status         :integer          default("not_contacted"), not null
#  personal_notes         :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  personal_space_list_id :bigint           not null, primary key
#  space_id               :bigint           not null, primary key
#
# Indexes
#
#  idx_on_personal_space_list_id_d490dca030                 (personal_space_list_id)
#  index_personal_data_on_space_in_lists_on_space_and_list  (space_id,personal_space_list_id) UNIQUE
#  index_personal_data_on_space_in_lists_on_space_id        (space_id)
#
# Foreign Keys
#
#  fk_rails_...  (personal_space_list_id => personal_space_lists.id)
#  fk_rails_...  (space_id => spaces.id)
#
