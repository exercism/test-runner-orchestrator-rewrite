require 'test_helper'

module Orchestrator
  class TestRunnerTest < Minitest::Test
    def test_uses_submission_container_version
      stub_spi_client!

      language = :ruby
      exercise = :bob
      uuid = "023949s9dads"
      s3_uri = "s3://test-exercism-submissions/test/testing/#{uuid}"

      timeout = 2000
      settings = LanguageSettings.new(:ruby, timeout, mock)

      container_version = "git-123asd"
      submission = Submission.new(language, exercise, uuid, container_version)

      conn = stub_platform_connection!
      conn.expects(:run_tests).with(language, exercise, s3_uri, container_version, timeout)

      test_runner = TestRunner.new(language, settings)
      test_runner.process_submission(submission)
    end

    def test_uses_default_container_container_version
      stub_spi_client!

      language = :ruby
      exercise = :bob
      uuid = "023949s9dads"
      s3_uri = "s3://test-exercism-submissions/test/testing/#{uuid}"

      submission_with_nil = Submission.new(language, exercise, uuid, nil)
      submission_with_blank = Submission.new(language, exercise, uuid, "")
      submission_with_none = Submission.new(language, exercise, uuid)

      container_version = "git-123asd"
      timeout = 2000
      settings = LanguageSettings.new(:ruby, timeout, container_version)

      conn = stub_platform_connection!
      conn.expects(:run_tests).with(language, exercise, s3_uri, container_version, timeout).times(3)

      test_runner = TestRunner.new(language, settings)
      test_runner.process_submission(submission_with_nil)
      test_runner.process_submission(submission_with_blank)
      test_runner.process_submission(submission_with_none)
    end

    def test_raises_for_no_workers
      data = JSON.parse({
        status: { status_code: 503 }
      }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))
      assert_raises(NoWorkersAvailableError) do
        runner.process_submission(Submission.new(:ruby, :bob, 123, "git..."))
      end
    end

    def test_posts_for_200s
      uuid = SecureRandom.uuid

      data = JSON.parse({
        status: { status_code: 200 }
      }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with do |p1, p2|
        p1 == uuid &&
        p2.is_a?(TestRun) &&
        p2.status_code == 200
      end

      runner.process_submission(Submission.new(:ruby, :bob, uuid, "git..."))
    end

    def test_posts_for_400s
      uuid = SecureRandom.uuid

      data = JSON.parse({
        status: { status_code: 400 }
      }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with do |p1, p2|
        p1 == uuid &&
        p2.is_a?(TestRun) &&
        p2.status_code == 400
      end

      runner.process_submission(Submission.new(:ruby, :bob, uuid, "git..."))
    end


  end
end
