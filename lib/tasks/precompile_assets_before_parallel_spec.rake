# frozen_string_literal: true

def precompile_assets_before(task_name)
  return unless Rake::Task.task_defined? task_name

  task = Rake::Task[task_name]

  task.enhance(["precompile_assets_once"])
end

# Enhance parallel:spec to precompile assets once, so it won't run per process
precompile_assets_before "parallel:spec"
