# frozen_string_literal: true

task build_fresh_js_and_css: :environment do
  system("yarn build")
  system("yarn build:css")
end

# Enhance the 'spec' task to get fresh js and css before running parallel specs
Rake::Task["parallel:spec"].enhance(["build_fresh_js_and_css"]) if Rake::Task.task_defined?("parallel:spec")
