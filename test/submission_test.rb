require 'test_helper'

module Orchestrator
  class SubmissionTest < Minitest::Test
    def test_symbolizes
      uuid = "5ac"
      submission = Submission.new('ruby', 'two-fer', uuid)
      assert_equal :ruby, submission.language
      assert_equal :"two-fer", submission.exercise
      assert_equal uuid, submission.uuid
    end
  end
end


