require 'test_helper'

module Orchestrator
  class SubmissionTest < Minitest::Test
    def test_symbolizes
      uuid = "5ac"
      submission = Submission.new(uuid, 'ruby', 'two-fer')
      assert_equal :ruby, submission.language
      assert_equal :"two-fer", submission.exercise
      assert_equal uuid, submission.uuid
    end

    def test_increment_errors_and_errored_too_many_times
      submission = Submission.new(nil, :ruby, :bob)
      refute submission.errored_too_many_times?

      submission.increment_errors!
      refute submission.errored_too_many_times?

      submission.increment_errors!
      refute submission.errored_too_many_times?

      submission.increment_errors!
      assert submission.errored_too_many_times?
    end
  end
end


