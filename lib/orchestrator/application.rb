module Orchestrator
  class Application
    def self.start!
      new.start!
    end

    def initialize
      @queue = Queue.new
      @language_processors = Hash.new {|h,k|h[k] = []}
      @language_settings = Hash.new {|h,k|h[k] = {}}
    end

    def start!
      # TODO - Retrieve languages from the SPI
      language_settings[:ruby] = LanguageSettings.new(:ruby, 2000, "git-abc123")

      add_language_processor(:ruby)
      add_language_processor(:javascript)
    end

    def enqueue_submission(submission)
      queue.push(submission)
    end

    def add_language_processor(language)
      lp = LanguageProcessor.run!(language, queue, language_settings[language])
      language_processors[language].push(lp)
    end

    private
    attr_reader :queue, :language_processors, :language_settings
  end
end
