# frozen_string_literal: true

def precompile_assets_before(task_name)
  return unless Rake::Task.task_defined? task_name

  task = Rake::Task[task_name]

  task.enhance(["assets:precompile"])
end

# Enhance both spec and parallel:spec to precompile assets and clobber them after, to simulate prod
precompile_assets_before "spec"
precompile_assets_before "parallel:spec"
