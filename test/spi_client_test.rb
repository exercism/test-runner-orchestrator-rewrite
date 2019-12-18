require 'test_helper'
require 'json'

module Orchestrator
  class SPIClientTest < Minitest::Test
    def test_calls_rest_client
      status_code = 300
      status_message = "Something happened"
      results = {"foo" => "bar"}
      submission_uuid = SecureRandom.uuid

      RestClient.expects(:post).with(
        "http://test-host.exercism.io/submissions/#{submission_uuid}/test_runs",
        {
          ops_status: status_code,
          ops_message: status_message,
          results: results
        }
      )
      SPIClient.post_test_run(submission_uuid, status_code, status_message, results)
    end
  end
end

