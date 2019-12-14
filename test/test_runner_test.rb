require 'test_helper'

module Orchestrator
  class TestRunnerTest < Minitest::Test
    def test_uses_submission_container_version
      language = :ruby
      exercise = :bob
      uuid = "023949s9dads"
      s3_uri = "s3://test-exercism-submissions/test/testing/#{uuid}"
      container_version = "git-123asd"
      submission = Submission.new(language, exercise, uuid, container_version)

      conn = stub_platform_connection!
      conn.expects(:run_tests).with(language, exercise, s3_uri, container_version)

      test_runner = TestRunner.new(language, mock)
      test_runner.process_submission(submission)
    end

    def test_uses_default_container_container_version
      language = :ruby
      exercise = :bob
      uuid = "023949s9dads"
      s3_uri = "s3://test-exercism-submissions/test/testing/#{uuid}"
      container_version = "git-123asd"
      submission_with_nil = Submission.new(language, exercise, uuid, nil)
      submission_with_blank = Submission.new(language, exercise, uuid, "")
      submission_with_none = Submission.new(language, exercise, uuid)

      conn = stub_platform_connection!
      conn.expects(:run_tests).with(language, exercise, s3_uri, container_version).times(3)

      test_runner = TestRunner.new(language, container_version)
      test_runner.process_submission(submission_with_nil)
      test_runner.process_submission(submission_with_blank)
      test_runner.process_submission(submission_with_none)
    end

  end
end
