# frozen_string_literal: true

task "precompile_assets_once" => :environment do
  next if ENV["TEST_ASSET_PRECOMPILE_DONE"]

  p "Compiling assets..."
  ENV["TEST_ASSET_PRECOMPILE_DONE"] = "true"
  compilation = Rake::Task["assets:precompile"].invoke

  abort "Pre-compilation failed. Cannot run tests." unless compilation

  p "Assets compiled"
end
