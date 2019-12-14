module Orchestrator
  class TestRunner
    def initialize(language, container_version)
      @language = language
      @default_container_version = container_version
      @platform_connection = PlatformConnection.new
    end

    def process_submission(submission)
      platform_connection.run_tests(
        submission.language,
        submission.exercise,
        submission.s3_uri,
        submission.container_version.presence || default_container_version
      )
    end

    private
    attr_reader :language, :default_container_version, :platform_connection
  end
end
