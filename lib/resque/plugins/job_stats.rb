require 'resque'
require 'resque/plugins/job_stats/performed'
require 'resque/plugins/job_stats/enqueued'
require 'resque/plugins/job_stats/failed'
require 'resque/plugins/job_stats/duration'
require 'resque/plugins/job_stats/timeseries'
require 'resque/plugins/job_stats/statistic'
require 'resque/plugins/job_stats/history'
require 'resque/plugins/job_stats/memory_usage'

module Resque
  module Plugins
    module JobStats
      include Resque::Plugins::JobStats::Enqueued
      include Resque::Plugins::JobStats::Duration
      include Resque::Plugins::JobStats::History
      include Resque::Plugins::JobStats::MemoryUsage

      def self.extended(base)
        self.measured_jobs << base
      end

      def self.measured_jobs
        @measured_jobs ||= []
      end
    end
  end
end
