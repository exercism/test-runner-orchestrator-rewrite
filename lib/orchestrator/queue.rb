module Orchestrator
  class Queue
    def initialize
      @submissions = Concurrent::MVar.new(Array.new)
    end

    def size
      submissions.borrow do |arr|
        arr.size
      end
    end

    def push(submission)
      submissions.borrow do |arr|
        arr.push(submission)
      end

      Logger.log_submission(submission, "Queued successfully")
    end

    def shift
      submissions.borrow do |arr|
        arr.shift
      end
    end

    private
    attr_reader :submissions
  end
end
