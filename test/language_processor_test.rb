require 'test_helper'

module Orchestrator
  class LanguageProcessorTest < Minitest::Test
    def test_runs_and_exits
      stub_platform_connection!

      queue = mock

      # TODO - Add a range of 9-11 here
      # This should be 1 / CHECK_FREQUENCY_MS.to_s
      queue.expects(:shift).with(language: :ruby).at_least(9)

      language_processor = LanguageProcessor.new(:ruby, queue, mock)

      # Sleep for one second then exit.
      Thread.new do
        sleep(1)

        # Exit first so we dont make this flakey
        # sleep should be 2x CHECK_FREQUENCY_MS.to_s
        language_processor.exit!
        queue.expects(:shift).never
        sleep(0.2)
      end

      Thread.expects(:new).yields
      language_processor.send(:run!)
    end

    def test_runs_a_submission_correctly
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

      with_language_processor(:ruby, queue, settings) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end
    end

    def test_sleeps_if_queue_is_empty
      stub_platform_connection!
      queue = mock
      queue.expects(:shift).with(language: :ruby).returns(nil).at_least_once

      with_language_processor(:ruby, queue, mock) do |language_processor|
        language_processor.expects(:sleep).with(0.1).at_least_once
        language_processor.run!
        sleep(0.1) # Sleep to let it happen
      end
    end
  end
end
