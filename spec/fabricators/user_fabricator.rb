# frozen_string_literal: true

Fabricator(:user) do
  email { "username@example.com" }
  first_name { Faker::Superhero.prefix + Faker::Superhero.descriptor }
  last_name { Faker::Superhero.suffix }
  email { Faker::Internet.email }
end

Fabricator(:user_with_no_organization, from: :user) do
  organization_boolean { false }
end

Fabricator(:user_with_organization, from: :user) do
  organization_name { Faker::Company.name }
  organization_boolean { true }
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  organization_boolean   :boolean
#  organization_name      :string
#  remember_created_at    :datetime
#  remember_token         :string(20)
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
