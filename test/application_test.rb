require 'test_helper'

module Orchestrator
  class ApplicationTest < Minitest::Test
    def test_enqueue_submission_proxies
      application = Application.new
      application.add_language(:ruby, nil, nil)
      application.add_language(:javascript, nil, nil)

      ruby_submission_1 = Submission.new(:ruby, :two_fer, 1)
      ruby_submission_2 = Submission.new(:ruby, :two_fer, 2)
      js_submission_1 = Submission.new(:javascript, :two_fer, 1)

      application.enqueue_submission(ruby_submission_1)
      assert_equal 1, application.queue_size(language: :ruby)
      assert_equal 0, application.queue_size(language: :javascript)

      application.enqueue_submission(ruby_submission_2)
      assert_equal 2, application.queue_size(language: :ruby)
      assert_equal 0, application.queue_size(language: :javascript)

      application.enqueue_submission(js_submission_1)
      assert_equal 2, application.queue_size(language: :ruby)
      assert_equal 1, application.queue_size(language: :javascript)
    end

    # This whole test is horrible in terms of checking
    # internals but it's also caught lots of integration
    # errors between all the pieces so I'm ok with it for now.
    def test_add_language_processor_proxies
      application = Application.new
      application.add_language(:ruby, nil, nil)
      application.add_language(:javascript, nil, nil)

      stub_platform_connection!(times: 3)
      stub_language_processor_run!(times: 3)

      application.add_processor(language: :ruby)
      application.add_processor(language: :javascript)
      application.add_processor(language: :ruby)

      assert_equal 2, application.num_processors(language: :ruby)
      assert_equal 1, application.num_processors(language: :javascript)
    end
  end
end

