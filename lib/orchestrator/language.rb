# This should be treated as an internal class
# Methods should not be accessed directly but
# instead through the Application class, which
# guarantees thread safety.
module Orchestrator
  class Language
    attr_reader :timeout_ms, :container_version

    def initialize(timeout_ms: ,
                   container_version: )
      @queue = Queue.new
      @processors = []
      @settings = LanguageSettings.new(
        timeout_ms: timeout_ms,
        container_version: container_version
      )
    end

    def add_processor
      lp = LanguageProcessor.run!(queue, settings)
      processors.push(lp)
    end

    def enqueue_submission(submission)
      queue.push(submission)
    end

    def queue_size
      queue.size
    end

    def num_processors
      processors.size
    end

    private
    attr_reader :queue, :processors, :settings
  end
end
