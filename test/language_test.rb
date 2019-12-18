require 'test_helper'

module Orchestrator
  class LanguageTest < Minitest::Test
    def test_queues
      language = Language.new(timeout_ms: nil, container_version: nil)

      ruby_submission_1 = Submission.new(:ruby, :two_fer, 1)
      ruby_submission_2 = Submission.new(:ruby, :two_fer, 2)

      language.enqueue_submission(ruby_submission_1)
      assert_equal 1, language.queue_size

      language.enqueue_submission(ruby_submission_2)
      assert_equal 2, language.queue_size
    end

    # This whole test is horrible in terms of checking
    # internals but it's also caught lots of integration
    # errors between all the pieces so I'm ok with it for now.
    def test_language_processors
      language = Language.new(timeout_ms: nil, container_version: nil)

      stub_platform_connection!(times: 2)
      stub_language_processor_run!(times: 2)

      language.add_processor
      language.add_processor

      assert_equal 2, language.num_processors
    end

    def test_settings
      timeout_ms = 1000
      container_version = "asdasdas"
      settings_hash = {"timeout_ms" => timeout_ms, "container_version" => container_version}
      language = Language.new(settings_hash)

      assert_equal timeout_ms, language.send(:settings).timeout_ms
      assert_equal container_version, language.send(:settings).container_version
    end
  end
end

