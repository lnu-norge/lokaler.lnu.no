# frozen_string_literal: true

class PersonalSpaceListsSpace < ApplicationRecord
  self.primary_key = [:space_id, :personal_space_list_id]

  belongs_to :personal_space_list
  belongs_to :space
  has_one :personal_data_on_space_in_list,
          query_constraints: [:space_id, :personal_space_list_id],
          dependent: :nullify

  after_create :set_up_personal_data_on_space_in_list

  def set_up_personal_data_on_space_in_list
    PersonalDataOnSpaceInList.find_or_create_by(personal_space_list:, space:)
  end
end

# == Schema Information
#
# Table name: personal_space_lists_spaces
#
#  personal_space_list_id :bigint           not null, primary key
#  space_id               :bigint           not null, primary key
#
# Indexes
#
#  index_personal_space_lists_spaces_on_personal_space_list_id  (personal_space_list_id)
#  index_personal_space_lists_spaces_on_space_id                (space_id)
#
