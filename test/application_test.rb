require 'test_helper'

module Orchestrator
  class ApplicationTest < Minitest::Test
    def test_enqueue_submission_proxies
      application = Application.new
      submission = Submission.new(:ruby, :two_fer, 1)
      application.enqueue_submission(submission)

      assert_equal submission, application.send(:queue).shift(language: :ruby)
    end

    def test_add_language_processor_proxies
      application = Application.new

      stub_platform_connection!(times: 3)
      stub_language_processor_run!(times: 3)

      application.add_language_processor(:ruby)
      application.add_language_processor(:javascript)
      application.add_language_processor(:ruby)

      assert_equal 2, application.send(:language_processors)[:ruby].size
      assert_equal 1, application.send(:language_processors)[:javascript].size
      assert_equal :ruby, application.send(:language_processors)[:ruby].first.send(:language)
      assert_equal :javascript, application.send(:language_processors)[:javascript].first.send(:language)
    end
  end
end

