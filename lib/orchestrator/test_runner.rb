module Orchestrator
  class TestRunner
    def initialize(language_settings)
      @language_settings = language_settings
      @platform_connection = PlatformConnection.new
    end

    def test_submission(submission)
      container_slug = submission.container_slug.presence ||
                       language_settings.container_slug

      TestRun.new(
        submission.uuid,
        platform_connection.run_tests(
          submission.language,
          submission.exercise,
          submission.s3_uri,
          container_slug,
          language_settings.timeout_ms
        )
      )
    end

    private
    attr_reader :language_settings, :platform_connection
  end
end
