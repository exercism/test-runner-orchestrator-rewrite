require 'test_helper'

module Orchestrator
  class LanguageSettingsTest < Minitest::Test
    def test_atoms
      timeout_ms = 1
      container_version = 'aasdasdasda'
      settings = LanguageSettings.new(
        'timeout_ms' => timeout_ms,
        'container_version' => container_version
      )

      assert_equal timeout_ms, settings.timeout_ms
      assert_equal container_version, settings.container_version
    end

    def test_update
      timeout_ms = 100
      container_version = 'adasasdqeqeqweqweqw'
      settings = LanguageSettings.new({})

      settings.update(
        'timeout_ms' => timeout_ms,
        'container_version' => container_version
      )

      assert_equal timeout_ms, settings.timeout_ms
      assert_equal container_version, settings.container_version
    end
  end
end
