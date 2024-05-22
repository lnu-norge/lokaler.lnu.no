# frozen_string_literal: true

class PersonalSpaceListsSpace < ApplicationRecord
  belongs_to :personal_space_list
  belongs_to :space

  enum contact_status: { not_contacted: 0, said_no: 1, said_maybe: 2, said_yes: 3 }
end

# == Schema Information
#
# Table name: personal_space_lists_spaces
#
#  id                     :bigint           not null, primary key
#  contact_status         :integer          default("not_contacted")
#  personal_notes         :text
#  personal_space_list_id :bigint           not null
#  space_id               :bigint           not null
#
# Indexes
#
#  index_personal_space_lists_spaces_on_personal_space_list_id  (personal_space_list_id)
#  index_personal_space_lists_spaces_on_space_id                (space_id)
#
