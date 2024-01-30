# frozen_string_literal: true

# rubocop:disable Rails/RakeEnvironment
# Rubocop Rails/RakeEnvironment breaks this function, as it needs to run
# before the environment is loaded.
task "precompile_assets_once" do
  next if ENV["TEST_ASSET_PRECOMPILE_DONE"]

  p "Compiling assets..."
  ENV["TEST_ASSET_PRECOMPILE_DONE"] = "true"
  compilation = Rake::Task["assets:precompile"].invoke

  abort "Pre-compilation failed. Cannot run tests." unless compilation

  p "Assets compiled"
end
# rubocop:enable Rails/RakeEnvironment
