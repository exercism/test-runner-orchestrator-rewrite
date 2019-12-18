require 'test_helper'

module Orchestrator
  class LanguageSettingsTest < Minitest::Test
    def test_atoms
      timeout_ms = 1
      container_slug = 'aasdasdasda'
      settings = LanguageSettings.new(
        'timeout_ms' => timeout_ms,
        'container_slug' => container_slug
      )

      assert_equal timeout_ms, settings.timeout_ms
      assert_equal container_slug, settings.container_slug
    end

    def test_update
      timeout_ms = 100
      container_slug = 'adasasdqeqeqweqweqw'
      settings = LanguageSettings.new({})

      settings.update(
        'timeout_ms' => timeout_ms,
        'container_slug' => container_slug
      )

      assert_equal timeout_ms, settings.timeout_ms
      assert_equal container_slug, settings.container_slug
    end
  end
end
