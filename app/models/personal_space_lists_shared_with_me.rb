# frozen_string_literal: true

class PersonalSpaceListsSharedWithMe < ApplicationRecord
  belongs_to :user
  belongs_to :personal_space_list

  validate :personal_space_list_shared_with_public

  default_scope lambda {
    includes(:personal_space_list)
      .where(personal_space_list: { shared_with_public: true })
  }

  private

  def personal_space_list_shared_with_public
    return if personal_space_list&.shared_with_public

    errors.add(:personal_space_list_id, "er ikke delt eller finnes ikke")
  end
end

# == Schema Information
#
# Table name: personal_space_lists_shared_with_mes
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  personal_space_list_id :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  idx_on_personal_space_list_id_d87a69044d               (personal_space_list_id)
#  index_personal_space_lists_shared_with_mes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (personal_space_list_id => personal_space_lists.id)
#  fk_rails_...  (user_id => users.id)
#
