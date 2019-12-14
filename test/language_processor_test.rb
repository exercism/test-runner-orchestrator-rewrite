require 'test_helper'

module Orchestrator
  class LanguageProcessorTest < Minitest::Test
    def test_runs_and_exits
      stub_platform_connection!

      queue = mock

      # TODO - Add a range of 9-11 here
      # This should be 1 / CHECK_FREQUENCY_MS.to_s
      queue.expects(:shift).with(language: :ruby).at_least(9)

      languge_processor = LanguageProcessor.run!(:ruby, queue, "git-...")
      sleep(1)

      # Exit first so we dont make this flakey
      # sleep should be 2x CHECK_FREQUENCY_MS.to_s
      languge_processor.exit!
      queue.expects(:shift).never
      sleep(0.2)
    end
  end
end
