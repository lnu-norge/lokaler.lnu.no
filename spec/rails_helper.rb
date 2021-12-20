# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'webdrivers'
require 'selenium-webdriver'
require 'vcr'

Webdrivers.install_dir = Rails.root + 'webdrivers' + ENV['TEST_ENV_NUMBER'].to_s


# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each do |f|
  require f
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request

  config.include Warden::Test::Helpers
  config.include Auth, type: :feature
  config.include TomSelect, type: :feature

  Webdrivers.cache_time = 86_400

  Capybara.register_driver :headless_chrome do |app|
    download_path = Rails.root + 'tmp/capybara/downloads'
    options = ::Selenium::WebDriver::Chrome::Options.new
    options.add_preference(:download, prompt_for_download: false, directory_upgrade: true, default_directory: download_path)
    options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
    options.add_preference(:safebrowsing, enabled: false, disable_download_protection: true )
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1920,1080')
    driver = Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: options)
    driver.browser.download_path = download_path
    driver
  end

  Capybara.default_max_wait_time = 10
  Capybara.javascript_driver = :headless_chrome
  Capybara.server = :puma, { Silent: true }


  VCR.configure do |config|
    config.cassette_library_dir = "spec/support/vcr"
    config.hook_into :webmock
    config.ignore_hosts 'chromedriver.storage.googleapis.com'
    config.ignore_hosts 'ws.geonorge.no'
    config.ignore_request do |request|
      uri = URI(request.uri)
      uri.host == '127.0.0.1' ||
        (uri.host == 'localhost' && uri.port != 3001) # Ignore localhost except on port 3001 which is used for recording KRA API cassettes
    end
  end
end
