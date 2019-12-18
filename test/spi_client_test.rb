require 'test_helper'
require 'json'

module Orchestrator
  class SPIClientTest < Minitest::Test
    def test_fetch_languages
      ruby_timeout = 3000
      ruby_container_version = "foobar"
      js_timeout = 1000
      js_container_version = "barfood"

      data = {
        'ruby' => {
          'timeout_ms' => ruby_timeout,
          'container_version' => ruby_container_version,
          'num_processors' => 3,
        },
        'javascript' => {
          'timeout_ms' => js_timeout,
          'container_version' => js_container_version,
          'num_processors' => 1,
        }
      }

      resp = { test_runners: data }.to_json
      RestClient.expects(:get).with("http://test-host.exercism.io/infrastructure/test_runners").returns(resp)
      assert_equal data, SPIClient.fetch_languages
    end

    def test_post_test_run
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

    def test_post_unknown_error
      submission_uuid = SecureRandom.uuid
      message = "Some error"

      RestClient.expects(:post).with(
        "http://test-host.exercism.io/submissions/#{submission_uuid}/test_runs",
        {
          ops_status: 500,
          ops_message: "An unknown error occurred. The exception message was: #{message}"
        }
      )
      SPIClient.post_unknown_error(submission_uuid, message)
    end
  end
end

