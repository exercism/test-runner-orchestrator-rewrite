module Orchestrator
  class TestRunner
    def initialize(language, language_settings)
      @language = language
      @language_settings = language_settings
      @platform_connection = PlatformConnection.new
    end

    def process_submission(submission)
      max_attempts = 40
      backoff_ms = 50

      container_version = submission.container_version.presence || language_settings.container_version
      test_run = TestRun.new(
        platform_connection.run_tests(
          submission.language,
          submission.exercise,
          submission.s3_uri,
          container_version,
          language_settings.timeout_ms
        )
      )

      raise NoWorkersAvailableError if test_run.no_wokers_available?

      SPIClient.post_test_run(submission.uuid, test_run)
    end

    private
    attr_reader :language, :language_settings, :platform_connection
  end
end
