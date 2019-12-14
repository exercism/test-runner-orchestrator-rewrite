require 'test_helper'

module Orchestrator
  class ApplicationTest < Minitest::Test
    def test_enqueue_proxies_to_queue
      application = Application.new

      submission = Submission.new(:ruby, :two_fer, 1)
      application.enqueue(submission)
      
      assert_equal submission, application.send(:queue).shift(language: :ruby)
    end
  end
end

