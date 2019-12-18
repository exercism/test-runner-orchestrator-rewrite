require 'test_helper'

module Orchestrator
  class TestRunnerTest < Minitest::Test
    def test_uses_submission_container_slug
      stub_spi_client!

      language = :ruby
      exercise = :bob
      uuid = "023949s9dads"
      s3_uri = "s3://test-exercism-submissions/test/testing/#{uuid}"
      timeout = 2000

      container_slug = "git-123asd"
      submission = Submission.new(uuid, language, exercise, container_slug)

      conn = stub_platform_connection!
      conn.expects(:run_tests).with(language, exercise, s3_uri, container_slug, timeout)

      test_runner = TestRunner.new(mock(timeout_ms: timeout))
      test_runner.process_submission(submission)
    end

    def test_uses_default_container_slug
      stub_spi_client!

      language = :ruby
      exercise = :bob
      uuid = "023949s9dads"
      s3_uri = "s3://test-exercism-submissions/test/testing/#{uuid}"

      submission_with_nil = Submission.new(uuid, language, exercise, nil)
      submission_with_blank = Submission.new(uuid, language, exercise, "")
      submission_with_none = Submission.new(uuid, language, exercise)

      container_slug = "git-123asd"
      timeout = 2000

      conn = stub_platform_connection!
      conn.expects(:run_tests).with(language, exercise, s3_uri, container_slug, timeout).times(3)

      settings = LanguageSettings.new(
        'timeout_ms' => timeout,
        'container_slug' => container_slug
      )
      test_runner = TestRunner.new(settings)
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

      runner = TestRunner.new(mock(timeout_ms: 100))
      assert_raises(NoWorkersAvailableError) do
        runner.process_submission(Submission.new(123, :ruby, :bob, "git..."))
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

      runner = TestRunner.new(mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with(uuid, status_code, message, results)

      submission = Submission.new(uuid, :ruby, :bob, "git...")
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

      runner = TestRunner.new(mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with(uuid, status_code, message, results)

      submission = Submission.new(uuid, :ruby, :bob, "git...")
      assert runner.process_submission(submission)
    end

    def test_raises_for_no_workers_avaliable
      data = JSON.parse({ status: { status_code: 503 }, }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock(timeout_ms: 100))

      submission = Submission.new(nil, :ruby, :bob, "git...")

      assert_raises NoWorkersAvailableError do
        runner.process_submission(submission)
      end
    end

    def test_increments_then_returns
      data = JSON.parse({ status: { status_code: 504 } }.to_json)

      platform_connection = stub_platform_connection!
      platform_connection.expects(:run_tests).returns(data)

      runner = TestRunner.new(mock(timeout_ms: 100))

      submission = Submission.new(nil, :ruby, :bob, "git...")
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

      runner = TestRunner.new(mock(timeout_ms: 100))
      SPIClient.expects(:post_test_run).with(uuid, status_code, message, results)

      submission = Submission.new(uuid, :ruby, :bob, "git...")
      submission.expects(:increment_errors!)
      submission.expects(:errored_too_many_times?).returns(true)
      assert runner.process_submission(submission)
    end
  end
end
