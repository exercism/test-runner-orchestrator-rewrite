module Orchestrator
  class LanguageSettings
    def initialize(hash)
      @timeout_ms_atom = Concurrent::Atom.new(nil)
      @version_slug_atom = Concurrent::Atom.new(nil)

      update(hash)
    end

    def update(hash)
      timeout_ms_atom.reset(hash['timeout_ms'].to_i)
      version_slug_atom.reset(hash['version_slug'])
    end

    def timeout_ms
      timeout_ms_atom.value
    end

    def version_slug
      version_slug_atom.value
    end

    private
    attr_reader :timeout_ms_atom, :version_slug_atom
  end
end
