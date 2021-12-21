# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# read the .ruby-version file to get the ruby version
ruby File.read(".ruby-version").strip

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 6.1.4", ">= 6.1.4.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Active Storage variant
gem "image_processing"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

group :production do
  gem "aws-sdk-s3"
  gem "newrelic_rpm"
end

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "fabrication"
  gem "faker"
  gem "parallel_tests"
  gem "scout_apm"
end

group :development do
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "foreman"
  gem "guard"
  gem "guard-livereload", require: false
  gem "guard-rspec", require: false
  gem "listen", "~> 3.3"
  gem "overcommit"
  gem "rack-mini-profiler", "~> 2.0"
  gem "rails-erd"
  gem "rubocop", require: false
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
end

group :test do
  gem "capybara"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "vcr"
  gem "webdrivers"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "devise", "~> 4.8"

gem "activerecord-import"
gem "addressable"
gem "diffy"
gem "gravtastic"
gem "high_voltage", "~> 3.1"
gem "hotwire-rails"
gem "http"
gem "inline_svg"
gem "kaminari"
gem "paper_trail"
gem "phonelib"
gem "rails-i18n"
gem "sendgrid-ruby"
gem "simple_form"
gem "simple_form-tailwind"
gem "tailwindcss-rails-webpacker", "~> 0.1.2"
gem "validate_url"
