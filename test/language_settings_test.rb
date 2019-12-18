require 'test_helper'

module Orchestrator
  class LanguageSettingsTest < Minitest::Test
    def test_atoms
      timeout_ms = 1
      container_version = 'aasdasdasda'
      settings = LanguageSettings.new(
        timeout_ms: timeout_ms,
        container_version: container_version
      )

      assert_equal timeout_ms, settings.timeout_ms
      assert_equal container_version, settings.container_version
    end
  end
end
