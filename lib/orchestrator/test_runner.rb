module Orchestrator
  class TestRunner
    def initialize(language_settings)
      @language_settings = language_settings
      @platform_connection = PlatformConnection.new
    end

    def process_submission(submission)
      max_attempts = 40
      backoff_ms = 50

      container_version = submission.container_version.presence || language_settings.container_version
      test_run = TestRun.new(
        submission.uuid,
        platform_connection.run_tests(
          submission.language,
          submission.exercise,
          submission.s3_uri,
          container_version,
          language_settings.timeout_ms
        )
      )

      # If we've been successful or we've got an error that's not
      # going to change, then record it and exit successfully
      if test_run.ran_successfully? || test_run.permanent_error?
        test_run.post_to_spi!
        return true
      end

      # If we've got an avaliability error, then let's
      # push it back upstream to be dealt with.
      raise NoWorkersAvailableError if test_run.no_workers_available?

      # We've got some sort of retriable error. We increment
      # the errors on the submission and then decide if its worth
      # backing off or not.
      submission.increment_errors!

      # If we've failed too many times then post the result back
      # and then return successfully.
      if submission.errored_too_many_times?
        test_run.post_to_spi!
        return true
      end

      # If we get here we've got an error worth retrying, so let's
      # put it to the back of the queue and we'll give it another
      # go when we get there.
      return false
    end

    private
    attr_reader :language_settings, :platform_connection
  end
end
