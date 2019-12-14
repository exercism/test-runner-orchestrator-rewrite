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
  end
end
