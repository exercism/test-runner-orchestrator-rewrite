require 'test_helper'

module Orchestrator
  class ApplicationTest < Minitest::Test
    def test_enqueue_submission_proxies
      application = Application.new
      application.add_language(:ruby, {'num_processors' => 0})
      application.add_language(:javascript, {'num_processors' => 0})

      application.enqueue_submission(:ruby, :two_fer, 1)
      assert_equal 1, application.queue_size(language: :ruby)
      assert_equal 0, application.queue_size(language: :javascript)

      application.enqueue_submission(:ruby, :two_fer, 2)
      assert_equal 2, application.queue_size(language: :ruby)
      assert_equal 0, application.queue_size(language: :javascript)

      application.enqueue_submission(:javascript, :two_fer, 3)
      assert_equal 2, application.queue_size(language: :ruby)
      assert_equal 1, application.queue_size(language: :javascript)
    end

    # This whole test is horrible in terms of checking
    # internals but it's also caught lots of integration
    # errors between all the pieces so I'm ok with it for now.
    def test_add_language_processor_proxies
      stub_platform_connection!(times: 6)
      stub_language_processor_run!(times: 6)

      application = Application.new
      application.add_language(:ruby, {'num_processors' => 0})
      application.add_language(:javascript, {'num_processors' => 1})
      application.add_language(:csharp, {'num_processors' => 1})

      assert_equal 0, application.num_processors(language: :ruby)
      assert_equal 1, application.num_processors(language: :javascript)
      assert_equal 1, application.num_processors(language: :csharp)

      application.add_processor(language: :ruby)
      application.add_processor(language: :ruby)
      application.add_processor(language: :javascript)
      application.add_processor(language: :ruby)

      assert_equal 3, application.num_processors(language: :ruby)
      assert_equal 2, application.num_processors(language: :javascript)
      assert_equal 1, application.num_processors(language: :csharp)
    end
  end
end

