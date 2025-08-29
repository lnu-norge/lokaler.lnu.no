# frozen_string_literal: true

class Robot < User
  include Gravtastic

  gravtastic default: "robohash"

  # Helper methods for naming and creating robot users:
  def self.nsr
    bot_for("NSR", "Nasjonalt Skoleregister")
  end

  def self.brreg
    bot_for("BRREG", "Brønnøysundregistrene")
  end

  def self.bot_for(name, organization)
    find_or_create_by!(email: "#{name.downcase.gsub(/[^a-z0-9]/, '')}-robot@lokaler.lnu.no") do |robot|
      robot.first_name = "#{name} (Robot)"
      robot.last_name = ""
      robot.in_organization = true
      robot.organization_name = organization
    end
  end

  # Override Devise methods to prevent login
  def active_for_authentication?
    false
  end
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
