module Orchestrator
  class LanguageSettings
    def initialize(hash)
      @timeout_ms_atom = Concurrent::Atom.new(nil)
      @container_version_atom = Concurrent::Atom.new(nil)

      update(hash)
    end

    def update(hash)
      timeout_ms_atom.reset(hash['timeout_ms'])
      container_version_atom.reset(hash['container_version'])
    end

    def timeout_ms
      timeout_ms_atom.value
    end

    def container_version
      container_version_atom.value
    end

    private
    attr_reader :timeout_ms_atom, :container_version_atom
  end
end
