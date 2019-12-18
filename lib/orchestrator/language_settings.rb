module Orchestrator
  class LanguageSettings
    def self.from_hash(hash)
      new(
        timeout_ms: hash['timeout_ms'],
        container_version: hash['container_version']
      )
    end

    def initialize(timeout_ms:, container_version:)
      @timeout_ms_atom = Concurrent::Atom.new(timeout_ms)
      @container_version_atom = Concurrent::Atom.new(container_version)
    end

    def timeout_ms
      timeout_ms_atom.value
    end

    def container_version
      container_version_atom.value
    end

    attr_reader :timeout_ms_atom, :container_version_atom
  end
end
