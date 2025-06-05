# frozen_string_literal: true

Fabricator(:login_attempt) do
  user
  email { |attrs| attrs[:user]&.email || "user@example.com" }
  login_method "magic_link"
  status "pending"
  failed_reason nil
end

# == Schema Information
#
# Table name: login_attempts
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  failed_reason :string
#  login_method  :string           not null
#  status        :string           default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint
#
# Indexes
#
#  index_login_attempts_on_email    (email)
#  index_login_attempts_on_status   (status)
#  index_login_attempts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
