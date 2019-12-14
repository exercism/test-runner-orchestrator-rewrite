module Orchestrator
  class PlatformConnection

    ADDRESS = "tcp://analysis-router.exercism.io:5555"

    # TODO: Would this be safer as a constant?
    def self.zmq_context
      @zmq_context ||= Concurrent::MVar.new(ZMQ::Context.new(1))
    end

    def initialize(address: ADDRESS)
      @address = address
      @socket = open_socket
    end

    private
    attr_reader :address, :socket

    def open_socket
      # Although this is never used outside of this method,
      # it must be set as an instance variable so that it
      # doesn't get garbage collected accidently.

      socket = PlatformConnection.zmq_context.borrow do |context|
        context.socket(ZMQ::REQ)
      end

      socket.linger = 1
      socket.connect(address)
      socket
    end

  def run_tests(track_slug, exercise_slug, s3_uri, container_version)
    test_run_id = "test-#{Time.now.to_i}"
    params = {
      action: :test_solution,
      id: test_run_id,
      track_slug: track_slug,
      exercise_slug: exercise_slug,
      s3_uri: s3_uri,
      container_version: container_version
      # "b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb",
      # container_version: "sha-122a036658c815c2024c604046692adc4c23d5c1",
    }
    timeout = Orchestrator::TRACKS[track_slug][:timeout]
    params[:execution_timeout] = timeout / 1000
    client_timeout = timeout + 2000
    send_recv(params, client_timeout)
  end

  end
end
