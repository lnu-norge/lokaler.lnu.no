# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# read the .ruby-version file to get the ruby version
ruby File.read(".ruby-version").strip

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"
# Use Puma as the app server
gem "puma", "~> 8.0"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.14"

# Still using sprockets, might remove later
gem "sprockets-rails", require: "sprockets/railtie"

# Use Active Storage variant
gem "image_processing"
# image_processing 2.0 no longer depends on a backend itself; Active Storage
# defaults to the vips processor, so declare ruby-vips explicitly.
gem "ruby-vips", "~> 2.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.18.6", require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

gem "devise", "~> 5.0"
gem "devise-i18n"
gem "devise-passwordless"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

gem "activerecord-import"
gem "activerecord-postgis-adapter" # For PostGIS and Geo commands in Active record
gem "addressable"
gem "chartkick" # Charts
gem "cssbundling-rails"
gem "csv"
gem "diffy"
gem "gravtastic"
gem "groupdate" # for grouping models by date
gem "high_voltage"
gem "http"
gem "inline_svg"
gem "jsbundling-rails"
gem "mission_control-jobs" # for seeing solid_queue jobs
gem "pagy"
gem "paper_trail"
gem "parallel"
gem "phonelib"
gem "postmark-rails"
gem "rails-i18n"
gem "rgeo-geojson" # For parsing geo json when importing from Geo Norge
gem "simple_form"
gem "simple_form-tailwind"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "stimulus-rails"
gem "turbo-rails"
gem "validate_url"

group :production, :staging do
  gem "aws-sdk-s3"
  gem "newrelic_rpm"
  # Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
  gem "kamal", require: false
  # Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
  gem "thruster", require: false
end

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri windows]
  gem "dotenv-rails"
  gem "fabrication"
  gem "faker"
  gem "parallel_tests"
  gem "scout_apm"
end

group :development do
  gem "annotaterb"
  gem "dockerfile-rails"
  gem "foreman"
  gem "guard"
  gem "guard-livereload", require: false
  gem "guard-rspec", require: false
  gem "letter_opener"
  gem "listen"
  gem "overcommit"
  gem "rack-livereload", require: false
  gem "rack-mini-profiler"
  gem "rails-erd"
  gem "rails_real_favicon"
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
  gem "web-console"
end

group :test do
  # No longer a default gem from Ruby 3.5 on; required by spec/support/performance_benchmark.rb
  gem "benchmark"
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "playwright-ruby-client", "~> 1.62.0"
  gem "rspec-benchmark"
  gem "rspec-rails"
  gem "vcr"
  gem "webmock"
end
