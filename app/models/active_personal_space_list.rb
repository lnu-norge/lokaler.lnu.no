# frozen_string_literal: true

class ActivePersonalSpaceList < ApplicationRecord
  belongs_to :user
  belongs_to :personal_space_list

  validates :user, uniqueness: true
end

# == Schema Information
#
# Table name: active_personal_space_lists
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  personal_space_list_id :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_active_personal_space_lists_on_personal_space_list_id  (personal_space_list_id)
#  index_active_personal_space_lists_on_user_id                 (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (personal_space_list_id => personal_space_lists.id)
#  fk_rails_...  (user_id => users.id)
#
