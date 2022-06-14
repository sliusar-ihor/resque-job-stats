require 'get_process_mem'

module Resque
  module Plugins
    module JobStats
      module MemoryUsage
        MEMORY_PERIOD_EXPIRE = {:day => 60 * 60 * 24, :month => 60 * 60 * 24 * 30}

        def jobs_memory_usage_key
          "stats:jobs:#{self.name}:memory_usage"
        end

        def around_perform_job_stats_memory_usage(*args)
          yield
          memory_usage = GetProcessMem.new.mb.round(2)
          job_memory_usage_increx_per(memory_usage, :day)
          job_memory_usage_increx_per(memory_usage, :month)
        end

        def job_memory_usage_avg_day
          _total, _count, _peak, avg = job_memory_usage_per(:day)
          avg
        end

        def job_memory_usage_avg_month
          _total, _count, _peak, avg = job_memory_usage_per(:month)
          avg
        end

        def peak_memory_usage_day
          _total, _count, peak, _avg = job_memory_usage_per(:day)
          peak
        end

        def peak_memory_usage_month
          _total, _count, peak, _avg = job_memory_usage_per(:month)
          peak
        end

        def job_memory_usage_increx_per(memory_usage, period)
          total, count, peak, _avg = job_memory_usage_per(period)
          Resque.redis.set(
            job_memory_usage_period_key(period),
            [
              total.to_f + memory_usage,
              count.to_i + 1,
              [peak.to_f, memory_usage].max,
              ((total.to_f + memory_usage)/(count.to_i + 1)).round(2)
            ])
          Resque.redis.expire(job_memory_usage_period_key(period), MEMORY_PERIOD_EXPIRE[period])
        end

        def job_memory_usage_per(period)
          JSON.parse(Resque.redis.get(job_memory_usage_period_key(period)) || "null")
        end

        def job_memory_usage_period_key(period)
          "#{jobs_memory_usage_key}:#{period}:#{Time.now.send(period)}"
        end
      end
    end
  end
end
