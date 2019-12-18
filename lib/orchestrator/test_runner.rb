module Orchestrator
  class TestRunner
    def initialize(language_settings)
      @language_settings = language_settings
      @platform_connection = PlatformConnection.new
    end

    def process_submission(submission)
      container_slug = submission.container_slug.presence ||
                       language_settings.container_slug

      test_run = TestRun.new(
        submission.uuid,
        platform_connection.run_tests(
          submission.language,
          submission.exercise,
          submission.s3_uri,
          container_slug,
          language_settings.timeout_ms
        )
      )

      # If we've been successful or we've got an error that's not
      # going to change, then record it and exit successfully
      if test_run.ran_successfully?
        Logger.log_submission(submission, "Testing succeeded")
        test_run.post_to_spi!
        Logger.log_submission(submission, "Reported back to SPI")
        return
      end

      if test_run.permanent_error?
        Logger.log_submission(submission, "Testing failed (#{test_run.status_code})")
        test_run.post_to_spi!
        Logger.log_submission(submission, "Reported back to SPI")
        return
      end

      # If we've got an error, so let's raise the exception
      # and we'll hadnle it upstream
      raise TestRunError.new(test_run)
    end

    private
    attr_reader :language_settings, :platform_connection
  end
end
