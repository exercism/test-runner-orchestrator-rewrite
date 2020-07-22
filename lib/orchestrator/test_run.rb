module Orchestrator
  class TestRun
    attr_reader :status_code

    def initialize(submission_uuid, data)
      @data = data
      @submission_uuid = submission_uuid
      @status_code = data&.fetch("status", nil)&.fetch("status_code", nil).to_i
      @status_message = data&.fetch("status", nil)&.fetch("message", nil)
      @results = data&.fetch("response", nil)
    end

    def post_to_spi!
      SPIClient.post_test_run(
        submission_uuid,
        status_code,
        status_message,
        results
      )
      Logger.log_submission(submission_uuid, "Failed with: #{data}") unless ran_successfully?
      Logger.log_submission(submission_uuid, "Reported back to SPI")
    end

    def ran_successfully?
      status_code == SUCCESS
    end

    def no_workers_available?
      [
        PLATFORM_NO_WORKER_AVAILABLE,
        CONTAINER_VERSION_UNAVALIABLE,
        CONTAINER_INVOCATION_FAILURE,
        CONTAINER_SETUP_FAILURE,
      ].include?(status_code)
    end

    def permanent_error?
      [
        BAD_INPUT,
        TIMEOUT,
        EXCESSIVE_IO,
        FORCED_EXIT,
        PLATFORM_ERROR,
        PLATFORM_UNRECOGNISED_ACTION,
        PLATFORM_MALFORMED_REQUEST,
        WORKER_ERROR,
        CONTAINER_OUTPUT_ERROR,
      ].include?(status_code)
    end

    private
    attr_reader :data, :submission_uuid, :status_message, :results

    SUCCESS = 200

    PLATFORM_NO_WORKER_AVAILABLE = 503
    PLATFORM_ERROR = 500
    PLATFORM_UNRECOGNISED_ACTION = 501
    PLATFORM_MALFORMED_REQUEST = 502
    PLATFORM_REQUEST_TIMED_OUT = 504

    WORKER_ERROR = 510
    CONTAINER_VERSION_UNAVALIABLE = 511
    CONTAINER_SETUP_FAILURE = 512
    CONTAINER_INVOCATION_FAILURE = 513
    CONTAINER_OUTPUT_ERROR = 514

    BAD_INPUT = 400
    TIMEOUT = 401
    EXCESSIVE_IO = 402
    FORCED_EXIT = 403
  end
end
