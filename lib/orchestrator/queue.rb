module Orchestrator
  class Queue
    def initialize
      @submissions = []
    end

    def push(submission)
      submissions.push(submission)
    end

    def shift(language: )
      idx = submissions.find_index {|s| s.language == language }
      submissions.delete_at(idx)
    end

    private
    attr_reader :submissions
  end
end
