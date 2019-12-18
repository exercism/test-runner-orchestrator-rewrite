require 'test_helper'

module Orchestrator
  class TestRunTest < Minitest::Test
    def test_ran_successfully
      assert TestRun.new(nil, {'status' => {'status_code' => 200}}).ran_successfully?

      refute TestRun.new(nil, {}).ran_successfully?
      refute TestRun.new(nil, {'status' => {'status_code' => 500}}).ran_successfully?
    end

    def test_no_workers_available
      assert TestRun.new(nil, {'status' => {'status_code' => 503}}).no_workers_available?
      assert TestRun.new(nil, {'status' => {'status_code' => 511}}).no_workers_available?

      refute TestRun.new(nil, {}).no_workers_available?
      refute TestRun.new(nil, {'status' => {'status_code' => 500}}).no_workers_available?
    end

    def test_permanent_error
      assert TestRun.new(nil, {'status' => {'status_code' => 400}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 401}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 402}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 403}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 500}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 501}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 502}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 510}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 513}}).permanent_error?
      assert TestRun.new(nil, {'status' => {'status_code' => 514}}).permanent_error?

      refute TestRun.new(nil, {}).permanent_error?
      refute TestRun.new(nil, {'status' => {'status_code' => 200}}).permanent_error?

      # Retriable errors
      refute TestRun.new(nil, {'status' => {'status_code' => 504}}).permanent_error?
      refute TestRun.new(nil, {'status' => {'status_code' => 512}}).permanent_error?
    end

    def test_post_to_spit
      submission_uuid = SecureRandom.uuid
      status_code = 200
      status_message = "foobar"
      results = {"something" => "else"}

      tr = TestRun.new(
        submission_uuid,
          {
          'status' => {'status_code' => status_code, 'message' => status_message},
          'response' => results
        }
      )

      SPIClient.expects(:post_test_run).with(
        submission_uuid,
        status_code,
        status_message,
        results
      )

      tr.post_to_spi!
    end
  end
end
