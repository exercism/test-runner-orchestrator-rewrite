module Orchestrator
  class TestRunner
    BACKOFF_MS = 50
    MAX_ATTEMPTS = 40

    def initialize(submission, platform_connection, language_settings)
      @submission = submission
      @platform_connection = platform_connection
      @language_settings = language_settings

      @num_attempts = 0
      @retry_unknown_error = true
    end

    def test!
      test_run = generate_test_run!

      # If we've been successful or we've got an error that's not
      # going to change, then record it and exit successfully
      if test_run.ran_successfully? || test_run.permanent_error?
        test_run.post_to_spi!
        return [true, test_run.status_code]
      end

      # If there are no workers avaliable then let's retry
      # this a few times with a backoff between each. Once
      # we hit the threshhold, we just treat this like any
      # other error.
      if test_run.no_workers_available?
        self.num_attempts += 1

        if num_attempts < MAX_ATTEMPTS
          sleep(BACKOFF_MS / 1000.0)
          return test!
        end
      end

      # We've got some sort of error, that's not automatically terminal.
      # We increment the number of errors on the submission and then
      # decide if its worth backing off or not.
      submission.increment_errors!

      # If we've failed too many times then post the result back
      if submission.errored_too_many_times?
        log("Too many errors. Giving up.")

        test_run.post_to_spi!
        return [true, test_run.status_code]
      end

      # Otherwise we've not handled it here so pass it back
      # upstream to be requeued.
      log("Errored. Attempting to requeue.")
      return [false, test_run.status_code]
    rescue => e
      return handle_bad_exception(e)
    end

    def generate_test_run!
      log("Starting testing #{submission.num_errored_test_runs + 1}/#{num_attempts + 1}")

      container_slug = submission.container_slug.presence ||
                       language_settings.container_slug

      data = platform_connection.run_tests(
        submission.language,
        submission.exercise,
        submission.s3_uri,
        container_slug,
        language_settings.timeout_ms
      )

      TestRun.new(submission.uuid, data).tap do |test_run|
        log("Finished testing (#{test_run.status_code})")
      end
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
    def handle_bad_exception(e)
      log("======")
      log("Exception while running tests (#{retry_unknown_error ? "first" : "second"} time)")
      log(e.class.name)
      log(e.message)
      log("------")

      if retry_unknown_error
        self.retry_unknown_error = false
        return test!
      end

      submission.increment_errors!
      return [false, 999] unless submission.errored_too_many_times?

      # Ensure that we catch this error too, so that we don't
      # exit the whole processor.
      #
      # TODO - We should definitely push this to Bugnsag
      begin
        SPIClient.post_unknown_error(submission.uuid, e.message)
      rescue => e
        log("======")
        log("Exception when posting error to SPI")
        log(e.class.name)
        log(e.message)
        log("------")
      end

      # At this stage, let's just get rid of the message
      return [true, 999]
    end

    private
    attr_reader :submission, :platform_connection, :language_settings

    protected
    attr_accessor :num_attempts, :retry_unknown_error

    def log(msg)
      Logger.log_submission(submission, msg)
    end
  end
end
