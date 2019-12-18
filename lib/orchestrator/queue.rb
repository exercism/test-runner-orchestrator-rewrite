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
    end

    def shift(language: )
      submissions.borrow do |arr|
        idx = arr.find_index {|s| s.language == language }
        idx ? arr.delete_at(idx) : nil
      end
    end

    private
    attr_reader :submissions
  end
end
