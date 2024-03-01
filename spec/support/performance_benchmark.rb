# frozen_string_literal: true

require "benchmark"
class PerformanceBenchmarkHighest
  def initialize(disabled: false)
    @start_times = {}
    @scores = []
    @disabled = disabled
  end

  def track_score_for(title:, &block)
    return yield block if @disabled

    time = Benchmark.measure do
      yield block
    end
    @scores << { title:, time: time.real, ms: (time.real * 1000).round(2) }
  end

  def start_timer_for(title)
    return if @disabled

    @start_times[title] = Time.zone.now
  end

  def end_timer_for(title)
    return if @disabled

    time = Time.zone.now - @start_times[title]
    add_time(title:, time:)

    @start_times[title] = nil
  end

  def highest_scores
    return if @disabled

    high_scores = @scores.group_by { |s| s[:title] }.map do |title, scores|
      highest = "#{scores.max_by { |s| s[:time] }[:ms]}ms"
      { "#{title}": highest, count: scores.count, total: "#{scores.sum { |s| s[:ms] }.round(2)}ms" }
    end
    puts "Highest times for each benchmark:"
    puts high_scores
  end

  private

  def add_time(title:, time:)
    @scores << { title:, time:, ms: (time * 1000).round(2) }
  end

  def filter_callers_to_only_project_files
    caller.select { |c| c.include?("/app/") }
  end
end
