# frozen_string_literal: true

Fabricator(:robot, class_name: :Robot) do
  email { "#{Faker::Internet.username(specifier: 3..10)}-robot@lokaler.lnu.no" }
  first_name { "#{Faker::Company.name.split.first} (Robot)" }
  last_name { "" }
  in_organization { true }
  organization_name { Faker::Company.name }
  type { "Robot" }
end

Fabricator(:nsr_robot, from: :robot) do
  email { "nsr-robot@lokaler.lnu.no" }
  first_name { "NSR (Robot)" }
  organization_name { "Nasjonalt Skoleregister" }
end

Fabricator(:brreg_robot, from: :robot) do
  email { "brreg-robot@lokaler.lnu.no" }
  first_name { "BRREG (Robot)" }
  organization_name { "Brønnøysundregistrene" }
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
#  in_organization        :boolean
#  last_name              :string
#  organization_name      :string
#  remember_created_at    :datetime
#  remember_token         :string(20)
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  type                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_type                  (type)
#
