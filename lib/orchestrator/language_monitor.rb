module Orchestrator
  class LanguageMonitor
    RECENT_S = (10 * 60)

    def initialize
      @results = Concurrent::Array.new
    end

    def record!(uuid, status)
      results.push([Time.now.to_i, uuid, status])
      prune_old_results!

      true
    end

    def recent_statuses
      threshold = (Time.now - RECENT_S).to_i
      results.select{|(t,_,_)| t > threshold}.map{|r|r[2]}
    end

    private
    attr_reader :results

    def prune_old_results!
      threshold = (Time.now - RECENT_S).to_i
      results.delete_if{|(t,_,_)| t < threshold}
    end
  end
end
