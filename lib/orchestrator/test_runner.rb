module Orchestrator
  class TestRunner
    def initialize(language, language_settings)
      @language = language
      @language_settings = language_settings
      @platform_connection = PlatformConnection.new
    end

    def process_submission(submission)
      container_version = submission.container_version.presence || language_settings.container_version
      platform_connection.run_tests(
        submission.language,
        submission.exercise,
        submission.s3_uri,
        container_version,
        language_settings.timeout_ms
      )
    end

    private
    attr_reader :language, :language_settings, :platform_connection
  end
end
