# frozen_string_literal: true

# Staging should be configured like production, unless overridden below
require File.expand_path("production.rb", __dir__)

Rails.application.configure do
  # Overrides go here
end
