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
          if should_exit.value
            handle_shutdown!
            break
          end
        end
      end
    end

    def exit!
      should_exit.value = true
    end

    private
    attr_reader :queue, :test_runner, :settings, :platform_connection
    attr_accessor :should_exit

    def initialize(queue, settings)
      @queue = queue
      @settings = settings
      @platform_connection = PlatformConnection.new
      @should_exit = Concurrent::AtomicBoolean.new(false)
    end

    def process_next_submission!
      submission = queue.shift
      return false unless submission

      handled = TestRunner.new(submission, platform_connection, settings).test!
      queue.push(submission) unless handled

      true
    end

    def handle_shutdown!
      # Handle anything to do with platform connection
    end
  end
end
