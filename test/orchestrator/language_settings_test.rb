require 'test_helper'

module Orchestrator
  class LanguageSettingsTest < Minitest::Test
    def test_atoms
      timeout_ms = 1
      version_slug = 'aasdasdasda'
      settings = LanguageSettings.new(
        'timeout_ms' => timeout_ms,
        'version_slug' => version_slug
      )

      assert_equal timeout_ms, settings.timeout_ms
      assert_equal version_slug, settings.version_slug
    end

    def test_update
      timeout_ms = 100
      version_slug = 'adasasdqeqeqweqweqw'
      settings = LanguageSettings.new({})

      settings.update(
        'timeout_ms' => timeout_ms,
        'version_slug' => version_slug
      )

      assert_equal timeout_ms, settings.timeout_ms
      assert_equal version_slug, settings.version_slug
    end
  end
end
