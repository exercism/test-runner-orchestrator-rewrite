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
          break if should_exit.value
        end
      end
    end

    def exit!
      should_exit.value = true
    end

    private
    attr_reader :queue, :test_runner
    attr_accessor :should_exit

    def initialize(queue, settings)
      @queue = queue
      @settings = settings
      @test_runner = TestRunner.new(settings)
      @should_exit = Concurrent::AtomicBoolean.new(false)
    end

    def process_next_submission!
      submission = queue.shift
      return false unless submission

      test_submission!(submission)
      true
    end

    def test_submission!(submission)
      backoff_ms = 50
      num_worker_available_attempts = 0
      max_worker_available_attempts = 40

      retry_unknown_error = true

      begin
        Logger.log_submission(submission, "Testing #{submission.num_errored_test_runs + 1}/#{num_worker_available_attempts + 1}")

        num_worker_available_attempts += 1
        test_runner.test_submission(submission)

      rescue TestRunError => e
        Logger.log_submission(submission, "Testing failed (#{e.test_run.status_code})")

        # If there are no workers avaliable then let's retry
        # this a few times ith a backoff between each
        if e.test_run.no_workers_available?
          if num_worker_available_attempts < max_worker_available_attempts
            sleep(backoff_ms / 1000.0)
            retry
          end
        end

        # We've got some sort of error, that's not automatically terminal.
        # We increment the number of errors on the submission and then
        # decide if its worth backing off or not.
        submission.increment_errors!

        # If we've failed too many times then post the result back
        # otherwise put it back on the queue for next time
        if submission.errored_too_many_times?
          Logger.log_submission(submission, "Too many errors. Giving up")
          e.test_run.post_to_spi!
          Logger.log_submission(submission, "Alerted SPI")
        else
          Logger.log_submission(submission, "Errored. Requeuing")
          queue.push(submission)
          Logger.log_submission(submission, "Requeued successfully")
        end

      # If we get to this rescue then something pretty
      # bad has happened. The most likely thing is that
      # the website has gone down and we can't connect
      # to the SPI or to 0mq. At this stage we're probably
      # in trouble and should requeue this message and
      # get out of here.
      #
      # Retry once in case of some sort of network glitch
      # otherwise add it back to the back of the queue.
      # If it *is* a problem with the solution this will
      # happen again and then we'll try sending it back to the
      # SPI. If that fails, we're just going to throw
      # this message away and we can deal with it upstream.
      #
      # TODO - We should probably push this to bugsnag
      rescue => e
        Logger.log_submission(submission, "======")
        Logger.log_submission(submission, "Exception while running tests (#{retry_unknown_error ? "first" : "second"} time)")
        Logger.log_submission(submission, e.class.name)
        Logger.log_submission(submission, e.message)
        Logger.log_submission(submission, "------")

        if retry_unknown_error
          retry_unknown_error = false
          retry
        end

        submission.increment_errors!
        unless submission.errored_too_many_times?
          queue.push(submission)
          return
        end

        # Ensure that we catch this error too, so that we don't
        # exit the whole processor.
        #
        # TODO - We should definitely push this to Bugnsag
        begin
          SPIClient.post_unknown_error(submission.uuid, e.message)
        rescue => e
          Logger.log_submission(submission, "======")
          Logger.log_submission(submission, "Exception when posting error to SPI")
          Logger.log_submission(submission, e.class.name)
          Logger.log_submission(submission, e.message)
          Logger.log_submission(submission, "------")
        end
      end
    end
  end
end
