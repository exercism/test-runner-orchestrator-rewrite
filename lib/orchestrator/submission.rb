module Orchestrator
  class Submission
    attr_reader :language, :exercise, :uuid, :container_version
    def initialize(language, exercise, uuid, container_version = nil)
      @language = language.to_sym
      @exercise = exercise.to_sym
      @uuid = uuid
      @container_version = container_version
    end
  end
end
