module Orchestrator
  class LanguageProcessor
    CHECK_FREQUENCY_MS = 100

    def self.run!(*args)
      new(*args).tap(&:run!)
    end

    def run!
      Thread.new do
        loop do
          submission_found = process_next_submission!

          # If the queue is empty, then let's back off
          # for the check_freqnency
          sleep(CHECK_FREQUENCY_MS / 1000.0) unless submission_found

          # Always check for this regardless of whether submission
          # was found or not.
          break if exit_asap.value
        end
      end
    end

    def exit!
      exit_asap.value = true
    end

    private
    attr_reader :queue, :test_runner
    attr_accessor :exit_asap

    def initialize(queue, settings)
      @queue = queue
      @settings = settings
      @test_runner = TestRunner.new(settings)
      @exit_asap = Concurrent::AtomicBoolean.new(false)
    end

    def process_next_submission!
      submission = queue.shift
      return false unless submission

      test_submission!(submission)
      true
    end

    def test_submission!(submission)
      max_attempts = 40
      backoff_ms = 50
      num_attempts = 0

      begin
        num_attempts += 1
        res = test_runner.process_submission(submission)
        queue.push(submission) unless res

      rescue NoWorkersAvailableError
        if num_attempts < max_attempts
          sleep(backoff_ms / 1000.0)
          retry
        end
      end
    end
  end
end
