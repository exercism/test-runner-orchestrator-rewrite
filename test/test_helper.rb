ENV["ENV"] = "test"

gem "minitest"
require "minitest/autorun"
require "minitest/pride"
require "minitest/mock"
require "mocha/minitest"
require "timecop"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

module Minitest
  class Test

    # This isn't used yet but probably will end up being
    # so I'm keeping it around for no.
=begin
    def stub_0mq!(times: 1)
      socket = mock
      socket.expects(:linger=).times(times)
      socket.expects(:connect).times(times).with("tcp://analysis-router.exercism.io:5555")

      context = mock
      context_wrapper = mock
      context_wrapper.stubs(:borrow).returns(socket)
      Orchestrator::PlatformConnection.expects(:zmq_context).times(times).returns(context_wrapper)
    end
=end

    def stub_language_processor_run!(times: 1)
      Orchestrator::LanguageProcessor.any_instance.expects(:run!).times(times)
    end

    def stub_platform_connection!(times: 1)
      Orchestrator::PlatformConnection.expects(:new).times(times)
    end
  end
end
