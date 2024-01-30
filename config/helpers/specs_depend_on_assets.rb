# frozen_string_literal: true

def specs_depend_on_assets?
  # Feature specs require assets
  return true if ARGV.join(" ").include? "spec/features"
  # Other, specifically mentioned tests, do not require assets
  return false if ARGV.join(" ").include? "spec/"

  # If in doubt, require assets
  true
end
