# frozen_string_literal: true

class Robot < User
  # Helper methods for naming and creating robot users:
  def self.nsr
    find_or_create_bot_for("NSR", "Nasjonalt Skoleregister")
  end

  def self.brreg
    find_or_create_bot_for("BRREG", "Brønnøysundregistrene")
  end

  # Override Devise methods to prevent login
  def active_for_authentication?
    false
  end

  private

  def find_or_create_bot_for(name, organization)
    find_or_create_by!(email: "#{name.downcase.gsub(/[^a-z0-9]/, '')}-robot@lokaler.lnu.no") do |robot|
      robot.first_name = "#{name} (Robot)"
      robot.last_name = ""
      robot.in_organization = true
      robot.organization_name = organization
    end
  end
end
