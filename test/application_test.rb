require 'test_helper'

module Orchestrator
  class ApplicationTest < Minitest::Test
    def test_enqueue_submission_proxies
      application = Application.new
      submission = Submission.new(:ruby, :two_fer, 1)
      application.enqueue_submission(submission)

      assert_equal submission, application.send(:queue).shift(language: :ruby)
    end

    # This whole test is horrible in terms of checking
    # internals but it's also caught lots of integration
    # errors between all the pieces so I'm ok with it for now.
    def test_add_language_processor_proxies
      ruby_language_settings = mock

      application = Application.new
      application.send(:language_settings)[:ruby] = ruby_language_settings

      stub_platform_connection!(times: 3)
      stub_language_processor_run!(times: 3)

      application.add_language_processor(:ruby)
      application.add_language_processor(:javascript)
      application.add_language_processor(:ruby)

      assert_equal 2, application.send(:language_processors)[:ruby].size
      assert_equal 1, application.send(:language_processors)[:javascript].size

      ruby = application.send(:language_processors)[:ruby].first
      assert_equal :ruby, ruby.send(:language)
      assert_equal application.send(:queue), ruby.send(:queue)
      assert_equal ruby_language_settings, ruby.send(:test_runner).send(:language_settings)
    end
  end
end

