require 'test_helper'

module Orchestrator
  class LanguageTest < Minitest::Test
    def test_queues
      language = Language.new(timeout_ms: nil, container_version: nil)

      ruby_submission_1 = Submission.new(1, :ruby, :two_fer)
      ruby_submission_2 = Submission.new(2, :ruby, :two_fer)

      language.enqueue_submission(ruby_submission_1)
      assert_equal 1, language.queue_size

      language.enqueue_submission(ruby_submission_2)
      assert_equal 2, language.queue_size
    end

    def test_scaling_language_processors_from_zero
      language = Language.new(timeout_ms: nil, container_version: nil)

      stub_platform_connection!(times: 2)
      stub_language_processor_run!(times: 2)

      language.scale_processors(2)
      assert_equal 2, language.num_processors
    end

    def test_scaling_language_processors_up
      language = Language.new(timeout_ms: nil, container_version: nil)

      stub_platform_connection!(times: 1)
      stub_language_processor_run!(times: 1)
      language.scale_processors(1)
      assert_equal 1, language.num_processors

      stub_platform_connection!(times: 2)
      stub_language_processor_run!(times: 2)
      language.scale_processors(3)
      assert_equal 3, language.num_processors
    end

    def test_scaling_language_processors_down
      language = Language.new(timeout_ms: nil, container_version: nil)

      Orchestrator::LanguageProcessor.any_instance.expects(:exit!).twice

      stub_platform_connection!(times: 3)
      stub_language_processor_run!(times: 3)

      language.scale_processors(3)
      assert_equal 3, language.num_processors

      language.scale_processors(1)
      assert_equal 1, language.num_processors
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

