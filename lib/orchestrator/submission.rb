module Orchestrator
  class Submission
    attr_reader :uuid, :language, :exercise, :version_slug
    def initialize(uuid, language, exercise, version_slug = nil)
      @uuid = uuid
      @language = language.to_sym
      @exercise = exercise.to_sym
      @version_slug = version_slug
      @num_errored_test_runs_atom = Concurrent::Atom.new(0)
    end

    def num_errored_test_runs
      num_errored_test_runs_atom.value
    end

    def increment_errors!
      num_errored_test_runs_atom.swap {|old| old + 1 }
    end

    def errored_too_many_times?
      num_errored_test_runs > 2
    end

    def s3_uri
      "s3://#{S3.bucket}/#{Orchestrator.env}/testing/#{uuid}"
    end

    protected
    attr_accessor :num_errored_test_runs_atom
  end
end
