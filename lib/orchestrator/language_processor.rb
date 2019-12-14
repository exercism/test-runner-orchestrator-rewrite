module Orchestrator
  class LanguageProcessor
    CHECK_FREQUENCY_MS = 100

    def self.run!(*args)
      new(*args).tap(&:run!)
    end

    def run!
      Thread.new do 
        loop do
          process_next_submission

          sleep(CHECK_FREQUENCY_MS / 1000.0)
          break if exit_asap.value
        end
      end
    end

    def exit!
      exit_asap.value = true
    end

    private
    attr_reader :language, :queue, :test_runner
    attr_accessor :exit_asap

    def initialize(language, queue, container_version)
      @language = language.to_sym
      @queue = queue
      @test_runner = TestRunner.new(language, container_version)
      @exit_asap = Concurrent::AtomicBoolean.new(false)
    end

    def process_next_submission
      submission = queue.shift(language: language)
      return unless submission

      test_runner.process_submission(submission)
    end
  end
end
