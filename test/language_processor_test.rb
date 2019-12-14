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

    def test_runs_and_exits
      language = :ruby
      exercise = :bob
      uuid = "023949s9dads"
      s3_uri = "s3://test-exercism-submissions/test/testing/#{uuid}"
      submission = Submission.new(language, exercise, uuid)
      queue = Queue.new
      queue.push(submission)

      timeout = 2000
      container_version = "git-123asd"
      settings = LanguageSettings.new(:ruby, timeout, container_version)

      conn = stub_platform_connection!
      conn.expects(:run_tests).with(language, exercise, s3_uri, container_version, timeout)

      languge_processor = LanguageProcessor.run!(language, queue, settings)
      sleep(0.1) # TODO - Ho do we get rid of this?
      languge_processor.exit!
    end
  end
end
