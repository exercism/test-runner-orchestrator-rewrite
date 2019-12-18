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
      status_code = 200
      message = "foobar"
      results = {"what" => "else"}

      data = JSON.parse({
        status: { status_code: status_code, message: message },
        response: results
      }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with(uuid, status_code, message, results)

      submission = Submission.new(:ruby, :bob, uuid, "git...")
      assert runner.process_submission(submission)
    end

    def test_posts_for_400s
      uuid = SecureRandom.uuid
      status_code = 400
      message = "foobar"
      results = {"what" => "else"}

      data = JSON.parse({
        status: { status_code: status_code, message: message },
        response: results
      }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with(uuid, status_code, message, results)

      submission = Submission.new(:ruby, :bob, uuid, "git...")
      assert runner.process_submission(submission)
    end

    def test_raises_for_no_workers_avaliable
      data = JSON.parse({ status: { status_code: 503 }, }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))

      submission = Submission.new(:ruby, :bob, nil, "git...")

      assert_raises NoWorkersAvailableError do
        runner.process_submission(submission)
      end
    end

    def test_increments_then_returns
      data = JSON.parse({ status: { status_code: 504 } }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))

      submission = Submission.new(:ruby, :bob, nil, "git...")
      submission.expects(:increment_errors!)
      submission.expects(:errored_too_many_times?).returns(false)
      refute runner.process_submission(submission)
    end

    def test_increments_then_posts
      uuid = SecureRandom.uuid
      status_code = 504
      message = "foobar"
      results = {"what" => "else"}

      data = JSON.parse({
        status: { status_code: status_code, message: message },
        response: results
      }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock, mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with(uuid, status_code, message, results)

      submission = Submission.new(:ruby, :bob, uuid, "git...")
      submission.expects(:increment_errors!)
      submission.expects(:errored_too_many_times?).returns(true)
      assert runner.process_submission(submission)
    end
  end
end
