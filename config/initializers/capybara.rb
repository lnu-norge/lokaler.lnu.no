# frozen_string_literal: true

# Solves issue https://github.com/teamcapybara/capybara/issues/2705
# when Capybara has a newer release than 3.39.2 it might be fixed
# and this file can be safely deleted.

if Rails.env.test?
  require "rackup"
  module Rack
    Handler = ::Rackup::Handler
  end
end
