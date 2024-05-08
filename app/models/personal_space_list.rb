# frozen_string_literal: true

class PersonalSpaceList < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :spaces
end

# == Schema Information
#
# Table name: personal_space_lists
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_personal_space_lists_on_user_id  (user_id)
#
