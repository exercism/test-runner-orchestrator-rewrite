module Orchestrator
  class LanguageSettings
    attr_reader :language, :timeout_ms, :container_version
    def initialize(language, timeout_ms, container_version)
      @language = language
      @timeout_ms = timeout_ms
      @container_version = container_version
    end
  end
end
