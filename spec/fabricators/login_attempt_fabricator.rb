# frozen_string_literal: true

Fabricator(:login_attempt) do
  user
  identifier Faker::Internet.user_name
  login_method "magic_link"
  status "pending"
  failed_reason nil
end

# == Schema Information
#
# Table name: login_attempts
#
#  id            :bigint           not null, primary key
#  failed_reason :string
#  identifier    :string           not null
#  login_method  :string           not null
#  status        :string           default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint
#
# Indexes
#
#  index_login_attempts_on_identifier_and_login_method  (identifier,login_method)
#  index_login_attempts_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
