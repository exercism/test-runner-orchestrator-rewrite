module Orchestrator
  class Submission
    attr_reader :uuid, :language, :exercise, :container_version
    def initialize(uuid, language, exercise, container_version = nil)
      @language = language.to_sym
      @exercise = exercise.to_sym
      @uuid = uuid
      @container_version = container_version
      @num_errored_test_runs = 0
    end

    def increment_errors!
      self.num_errored_test_runs += 1
    end

    def errored_too_many_times?
      num_errored_test_runs > 2
    end

    def s3_uri
      "s3://#{S3.bucket}/#{Orchestrator.env}/testing/#{uuid}"
    end

    protected
    attr_accessor :num_errored_test_runs
  end
end
