# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LokalerLnuNo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Propshaft publishes everything on its asset paths, where Sprockets only
    # precompiled what app/assets/config/manifest.js explicitly linked. These
    # three are inputs to postcss and esbuild rather than servable assets, so
    # without excluding them every partial stylesheet and every Stimulus
    # controller gets digested and shipped next to the real bundles.
    # Has to be set here: Propshaft applies excluded_paths in its own
    # append_assets_path initializer, which runs after config/initializers.
    config.assets.excluded_paths = [
      Rails.root.join("app/assets/stylesheets"),
      Rails.root.join("app/javascript"),
      Rails.root.join("vendor/javascript")
    ]

    # excluded_paths only catches part of it. Propshaft applies it as
    # `paths - excluded.collect(&:to_s)`, and the entries for app/javascript and
    # vendor/javascript are Pathname rather than String, so `-` never matches
    # them. Compare as strings once the paths are final.
    config.after_initialize do
      excluded = config.assets.excluded_paths.map(&:to_s)
      config.assets.paths.reject! { |path| excluded.include?(path.to_s) }
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Mission control
    config.mission_control.jobs.base_controller_class = "BaseControllers::AuthenticateAsAdminController"
    config.mission_control.jobs.http_basic_auth_enabled = false

    # Set default i18n translation to norwegian
    config.i18n.available_locales = %i[nb en]
    config.i18n.default_locale = :nb

    # This is needed to make the `reify` method work in the PaperTrail gem
    # as it stores the `item` as a YAML string, and the default ruby YAML parser
    # does not allow symbols as keys.
    config.active_record.yaml_column_permitted_classes = [Symbol, Hash, Array,
                                                          Date, Time, BigDecimal,
                                                          ActiveSupport::TimeWithZone,
                                                          ActiveSupport::TimeZone,
                                                          ActiveSupport::HashWithIndifferentAccess]
  end
end
