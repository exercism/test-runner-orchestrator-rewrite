module Orchestrator
  class Application
    def self.start!
      @instance = new

      # TODO - Retrieve languages from the SPI
      languages = [:ruby, :javascript]
    end

    # TODO - This is itself immutable so I think
    # it's threadsafe, although the things inside
    # of it need thread accessing.
    def self.instance
      @instance
    end

    def initialize
      @queue = Queue.new
    end

    def enqueue(submission)
      queue.push(submission)
    end
    
    private
    attr_reader :queue
  end
end
