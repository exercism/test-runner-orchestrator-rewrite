module Orchestrator
  class LanguageMonitor
    RECENT_S = (10 * 60)

    def initialize
      @results = Concurrent::MVar.new([])
    end

    def record!(uuid, status)
      results.borrow do |rs|
        rs.push([Time.now.to_i, uuid, status])
      end
      prune_old_results!

      true
    end

    def recent_statuses
      threshold = (Time.now - RECENT_S).to_i
      results.borrow do |rs|
        rs.select{|(t,_,_)| t > threshold}.map{|r|r[2]}
      end
    end

    private
    attr_reader :results

    def prune_old_results!
      threshold = (Time.now - RECENT_S).to_i

      results.borrow do |rs|
        rs.delete_if{|(t,_,_)| t < threshold}
      end
    end
  end
end
