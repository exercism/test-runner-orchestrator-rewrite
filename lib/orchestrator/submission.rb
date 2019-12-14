module Orchestrator
  class Submission
    attr_reader :language, :exercise, :uuid, :container_version
    def initialize(language, exercise, uuid, container_version = nil)
      @language = language.to_sym
      @exercise = exercise.to_sym
      @uuid = uuid
      @container_version = container_version
    end

    # TODO - Extract this to some helper builder method
    def s3_uri
      bucket = secrets['aws_submissions_bucket']
      path = "#{Orchestrator.env}/testing/#{uuid}"

      "s3://#{bucket}/#{path}"
    end

    def secrets
      @secrets ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../config/secrets.yml")).result)[Orchestrator.env]
    end

  end
end
