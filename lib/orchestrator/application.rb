module Orchestrator
  class Application
    def self.start!
      new.start!
    end

    def initialize
      @queue = Queue.new
      @language_processors = Hash.new {|h,k|h[k] = []}
    end

    def start!
      # TODO - Retrieve languages from the SPI
      add_language_processor(:ruby)
      add_language_processor(:javascript)
    end

    def enqueue_submission(submission)
      queue.push(submission)
    end

    def add_language_processor(language)

      # TODO - pass correct default container version
      lp = LanguageProcessor.run!(language, queue, "git-...")
      language_processors[language].push(lp)
    end

    private
    attr_reader :queue, :language_processors
  end
end
