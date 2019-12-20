module Orchestrator
  class PlatformConnection

    ADDRESS = "tcp://analysis-router.exercism.io:5555"

    # TODO: Would this be safer as a constant?
    # TODO - Yes it would!
    ZMQ_CONTEXT = Concurrent::MVar.new(ZMQ::Context.new(1))

    def initialize(address: ADDRESS)
      @address = address
      @socket = open_socket
    end

    def run_tests(track_slug, exercise_slug, s3_uri, version_slug, timeout_ms)
      test_run_id = "test-#{Time.now.to_i}"
      params = {
        action: :test_solution,
        id: test_run_id,
        track_slug: track_slug,
        exercise_slug: exercise_slug,
        s3_uri: s3_uri,
        container_version: version_slug
      }
      params[:execution_timeout] = timeout_ms / 1000.0
      client_timeout = timeout_ms + 2000

      send_msg(params.to_json, client_timeout)
    end

    def build_version(language_slug, version_slug)
      params = {
        channel: :test_runners,
        action: :build_container,
        track_slug: language_slug,
        git_reference: version_slug
      }
      result = send_msg(params.to_json, 1_000)
    end

    def deploy_version(language_slug, version_slug)
      params = {
        action: :deploy_container_version,
        track_slug: language_slug,
        channel: "test_runners",
        new_version: "git-#{version_slug}"
      }
      result = send_msg(params.to_json, 1_000)
    end

    def send_msg(json, timeout_ms)
      socket.linger = timeout_ms * 2
      socket.rcvtimeo = timeout_ms

      msg = ZMQ::Message.new
      msg.push(ZMQ::Frame.new(json))

      puts "Sending msg"
      socket.send_message(msg)

      # Get the response back from the runner
      puts "Waiting for response"
      recvd_msg = socket.recv_message

      return {
        "status" => {
          "status_code" => 101,
          "message" => "Client Timeout"
        }
      } if recvd_msg.nil?

      response = recvd_msg.pop.data

      return {
        "status"=> {
          "status_code" => 102,
          "message" => "Missing response",
          "error" => "Response was nil"
        }
      } if response.nil?


      begin
        JSON.parse(response)
      rescue JSON::ParserError => e
        puts e.message
        puts e.backtrace

        {
          "status" => {
            "status_code" => 103,
            "message" => "Malformed response",
            "error" => "Response was not valid JSON. Got #{response}"
          }
        }
      end
    end

    private
    attr_reader :address, :socket

    def open_socket
      # Although this is never used outside of this method,
      # it must be set as an instance variable so that it
      # doesn't get garbage collected accidently.

      socket = ZMQ_CONTEXT.borrow do |context|
        context.socket(ZMQ::REQ)
      end

      socket.linger = 1
      socket.connect(address)
      socket
    end
  end
end
